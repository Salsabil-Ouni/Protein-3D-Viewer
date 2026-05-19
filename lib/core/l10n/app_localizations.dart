/// Simple key-based localization for EN / FR.
/// Access via: AppL10n.tr(ref.watch(localeProvider), 'key')
class AppL10n {
  static const _en = {
    // Auth
    'app_name': 'Protein3D Viewer',
    'tagline': 'Sign in to explore protein structures',
    'email': 'Email',
    'password': 'Password',
    'sign_in': 'Sign In',
    'sign_out': 'Sign Out',
    'register': 'Register',
    'no_account': "Don't have an account?",
    'already_account': 'Already have an account?',
    'first_name': 'First Name',
    'last_name': 'Last Name',
    'demo_creds': 'Use demo credentials',
    'firebase_active': 'Firebase Auth Active',
    'local_auth': 'Local Auth (Firebase not configured)',
    // Home
    'search_hint': 'Search proteins, PDB IDs...',
    'featured': 'Featured Structures',
    'recent': 'Recent Searches',
    'clear': 'Clear',
    'my_favorites': 'My Favorites',
    'search_pdb': 'Search PDB',
    // Detail tabs
    'overview': 'Overview',
    'properties': 'Properties',
    'sequence': 'Sequence',
    'ai_analysis': 'AI Analysis',
    // Overview
    'basic_info': 'Basic Information',
    'pdb_id': 'PDB ID',
    'title': 'Title',
    'organism': 'Organism',
    'method': 'Exp. Method',
    'resolution': 'Resolution',
    'chains': 'Chains',
    'released': 'Released',
    'keywords': 'Keywords',
    // Properties
    'physicochemical': 'Physicochemical Properties',
    'mol_weight': 'Molecular Weight',
    'iso_point': 'Isoelectric Point (pI)',
    'instability': 'Instability Index',
    'aliphatic': 'Aliphatic Index',
    'stable': 'Stable',
    'unstable': 'Unstable',
    'radar': 'Radar Overview',
    'aa_composition': 'Amino Acid Composition (top 10)',
    // Sequence
    'seq_not_available': 'Sequence not available',
    'residues': 'residues',
    // AI
    'ai_title': 'AI Protein Analysis',
    'ai_subtitle': 'Powered by Google Gemini',
    'ai_button': 'Analyze with AI',
    'ai_analyzing': 'Analyzing…',
    'ai_key_missing': 'Gemini API key not configured.\nSet ApiConstants.geminiApiKey in api_constants.dart.',
    'ai_error': 'Analysis failed',
    'ai_retry': 'Retry',
    // Connectivity
    'offline': 'No internet connection',
    // Misc
    'retry': 'Retry',
    'added_fav': 'added to favorites',
    'removed_fav': 'removed from favorites',
    'lang_toggle': 'FR',
    // Search screen
    'search_recent': 'Recent Searches',
    'search_quick': 'Quick Access',
    'search_input_hint': 'Search by name or PDB ID…',
    'search_clear': 'Clear',
    // Sequence tab
    'copy_sequence': 'Copy',
    'copied': 'Sequence copied!',
    // Overview tab
    'download_pdb': 'Download PDB File',
    // Favorites
    'no_favorites': 'No favorites yet.\nTap ♡ on any protein to save it.',
    // Profile / drawer
    'confirm_password': 'Confirm Password',
    'passwords_no_match': 'Passwords do not match',
  };

  static const _fr = {
    // Auth
    'app_name': 'Protein3D Viewer',
    'tagline': 'Connectez-vous pour explorer les structures',
    'email': 'Email',
    'password': 'Mot de passe',
    'sign_in': 'Se connecter',
    'sign_out': 'Se déconnecter',
    'register': "S'inscrire",
    'no_account': 'Pas encore de compte ?',
    'already_account': 'Déjà un compte ?',
    'first_name': 'Prénom',
    'last_name': 'Nom',
    'demo_creds': 'Identifiants de démo',
    'firebase_active': 'Firebase Auth Actif',
    'local_auth': 'Auth Locale (Firebase non configuré)',
    // Home
    'search_hint': 'Rechercher des protéines, IDs PDB…',
    'featured': 'Structures en vedette',
    'recent': 'Recherches récentes',
    'clear': 'Effacer',
    'my_favorites': 'Mes favoris',
    'search_pdb': 'Rechercher PDB',
    // Detail tabs
    'overview': 'Aperçu',
    'properties': 'Propriétés',
    'sequence': 'Séquence',
    'ai_analysis': 'Analyse IA',
    // Overview
    'basic_info': 'Informations de base',
    'pdb_id': 'ID PDB',
    'title': 'Titre',
    'organism': 'Organisme',
    'method': 'Méthode exp.',
    'resolution': 'Résolution',
    'chains': 'Chaînes',
    'released': 'Publié le',
    'keywords': 'Mots-clés',
    // Properties
    'physicochemical': 'Propriétés physicochimiques',
    'mol_weight': 'Poids moléculaire',
    'iso_point': 'Point isoélectrique (pI)',
    'instability': "Indice d'instabilité",
    'aliphatic': 'Indice aliphatique',
    'stable': 'Stable',
    'unstable': 'Instable',
    'radar': 'Radar des propriétés',
    'aa_composition': 'Composition en acides aminés (top 10)',
    // Sequence
    'seq_not_available': 'Séquence non disponible',
    'residues': 'résidus',
    // AI
    'ai_title': 'Analyse IA de la protéine',
    'ai_subtitle': 'Propulsé par Google Gemini',
    'ai_button': 'Analyser avec IA',
    'ai_analyzing': 'Analyse en cours…',
    'ai_key_missing': 'Clé API Gemini non configurée.\nDéfinissez ApiConstants.geminiApiKey.',
    'ai_error': 'Analyse échouée',
    'ai_retry': 'Réessayer',
    // Connectivity
    'offline': 'Pas de connexion internet',
    // Misc
    'retry': 'Réessayer',
    'added_fav': 'ajouté aux favoris',
    'removed_fav': 'retiré des favoris',
    'lang_toggle': 'EN',
    // Search screen
    'search_recent': 'Recherches récentes',
    'search_quick': 'Accès rapide',
    'search_input_hint': 'Rechercher par nom ou ID PDB…',
    'search_clear': 'Effacer',
    // Sequence tab
    'copy_sequence': 'Copier',
    'copied': 'Séquence copiée !',
    // Overview tab
    'download_pdb': 'Télécharger le fichier PDB',
    // Favorites
    'no_favorites': 'Aucun favori.\nAppuyez sur ♡ pour sauvegarder.',
    // Profile / drawer
    'confirm_password': 'Confirmer le mot de passe',
    'passwords_no_match': 'Les mots de passe ne correspondent pas',
  };

  static String tr(String locale, String key) =>
      _strings(locale)[key] ?? _strings('en')[key] ?? key;

  static Map<String, String> _strings(String locale) =>
      locale == 'fr' ? _fr : _en;
}
