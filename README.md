
# project

lib-->ui-->fullApps-->HotelBooking.dart
Fait:
- firestore authentification login et password
- sign in et sign up
- Créer un formulaire d'ajout pour envoi vers firestore

A faire:
- Afficher des data sur l'application mobile à partir de la sous collection "menu.dart" d'un seller
  à s'entrainer via : navigationHomeScreen.dart et sectionviw.dart par categorie

Column(children: [
SectionView(title: labels[0], hotelList: recommendedHotelList),
SectionView(title: labels[1], hotelList: topRatedHotelList),
SectionView(title: labels[2], hotelList: bookMarkedHotelList),
SectionView(title: labels[3], hotelList: popularHotelList),
SectionView(title: labels[4], hotelList: trendingHotelList),
SectionView(title: labels[5], hotelList: topCheapestHotelList),
])





