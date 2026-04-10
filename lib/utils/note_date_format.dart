/// Affichage des dates façon Notes : mois courant → jour + mois ;
/// même année mais autre mois → nom du mois ; autre année → année.
library;

const List<String> _moisCourt = <String>[
  '',
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

const List<String> _moisLong = <String>[
  '',
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

bool _memeJourCalendaire(DateTime a, DateTime b) {
  final la = a.toLocal();
  final lb = b.toLocal();
  return la.year == lb.year && la.month == lb.month && la.day == lb.day;
}

String titreSectionMois(int year, int month, [DateTime? reference]) {
  final ref = (reference ?? DateTime.now()).toLocal();
  final mois = _moisLong[month];
  if (mois.isEmpty) return '';
  final capitalise = mois[0].toUpperCase() + mois.substring(1);
  if (year == ref.year) {
    return capitalise;
  }
  return '$capitalise $year';
}

String formatDateRelativeListe(DateTime d, [DateTime? reference]) {
  final ref = (reference ?? DateTime.now()).toLocal();
  final dl = d.toLocal();
  if (_memeJourCalendaire(dl, ref)) {
    return 'Aujourd\'hui';
  }
  if (dl.year == ref.year && dl.month == ref.month) {
    return '${dl.day} ${_moisCourt[dl.month]}';
  }
  if (dl.year == ref.year) {
    return _moisLong[dl.month];
  }
  return '${dl.year}';
}

String formatDateRelativeDetail(DateTime d, [DateTime? reference]) {
  final ref = (reference ?? DateTime.now()).toLocal();
  final dl = d.toLocal();
  final h = dl.hour.toString().padLeft(2, '0');
  final m = dl.minute.toString().padLeft(2, '0');
  final time = '$h:$m';
  if (_memeJourCalendaire(dl, ref)) {
    return 'Aujourd\'hui à $time';
  }
  if (dl.year == ref.year && dl.month == ref.month) {
    return '${dl.day} ${_moisCourt[dl.month]} à $time';
  }
  if (dl.year == ref.year) {
    return '${dl.day} ${_moisLong[dl.month]} à $time';
  }
  return '${dl.day} ${_moisLong[dl.month]} ${dl.year} à $time';
}
