import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/protein_model.dart';
//firestore + hive
abstract class ProteinRemoteDataSource {
  Future<ProteinDetailModel> getProteinDetail(String pdbId);
  Future<List<ProteinModel>> searchProteins(String query);
}

class ProteinRemoteDataSourceImpl implements ProteinRemoteDataSource {
  final DioClient _dioClient;

  ProteinRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ProteinDetailModel> getProteinDetail(String pdbId) async {
    try {
      final id = pdbId.toLowerCase();

      // 1. Fetch entry-level data
      final entryResp = await _dioClient.pdb.get('/entry/$id');
      final entryData = entryResp.data as Map<String, dynamic>;

      // 2. Get polymer entity IDs from the entry
      final entityIds = List<String>.from(
        entryData['rcsb_entry_container_identifiers']?['polymer_entity_ids'] ?? ['1'],
      );

      // 3. Fetch each polymer entity (sequence + chain info)
      final entities = <Map<String, dynamic>>[];
      for (final eid in entityIds.take(8)) {
        try {
          final r = await _dioClient.pdb.get('/polymer_entity/$id/$eid');
          entities.add(r.data as Map<String, dynamic>);
        } catch (_) {}
      }

      return ProteinDetailModel.fromEntryAndEntities(entryData, pdbId.toUpperCase(), entities);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException('Protein $pdbId not found in PDB database.');
      }
      throw ServerException(e.message ?? 'Failed to fetch protein data.');
    }
  }

  @override
  Future<List<ProteinModel>> searchProteins(String query) async {
    try {
      final searchDio = Dio(BaseOptions(
        baseUrl: ApiConstants.pdbSearchUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ));

      final payload = {
        'query': {
          'type': 'terminal',
          'service': 'full_text',
          'parameters': {'value': query},
        },
        'return_type': 'entry',
        'request_options': {
          'paginate': {'start': 0, 'rows': 20},
          'sort': [{'sort_by': 'score', 'direction': 'desc'}],
        },
      };

      final resp = await searchDio.post('', data: payload);
      final results = (resp.data['result_set'] as List?) ?? [];

      final proteins = <ProteinModel>[];
      for (final r in results.take(10)) {
        try {
          final id = r['identifier'] as String;
          final detail = await getProteinDetail(id);
          proteins.add(ProteinModel(
            pdbId: detail.pdbId,
            title: detail.title,
            organism: detail.organism,
            method: detail.method,
            resolution: detail.resolution,
            chainCount: detail.chainCount,
            releaseDate: detail.releaseDate,
            thumbnailUrl: detail.thumbnailUrl,
          ));
        } catch (_) {
          continue;
        }
      }
      return proteins;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Search failed.');
    }
  }
}
