/// A single dhikr/azkar entry: Arabic text plus a short English gloss.
class Azkar {
  const Azkar(this.arabic, this.translation);

  final String arabic;
  final String translation;
}

/// A pool of well-known, widely reproduced azkar (remembrance phrases),
/// drawn from common daily-dhikr collections such as Hisnul Muslim. These
/// are traditional religious texts, not copyrighted literary works.
const azkarPool = [
  Azkar('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', 'Glory be to Allah and praise Him'),
  Azkar('سُبْحَانَ اللَّهِ الْعَظِيمِ', 'Glory be to Allah, the Most Great'),
  Azkar('الْحَمْدُ لِلَّهِ', 'All praise is due to Allah'),
  Azkar('اللَّهُ أَكْبَرُ', 'Allah is the Greatest'),
  Azkar('لَا إِلَهَ إِلَّا اللَّهُ', 'There is no god but Allah'),
  Azkar('أَسْتَغْفِرُ اللَّهَ', 'I seek forgiveness from Allah'),
  Azkar('لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ', 'There is no power nor strength except with Allah'),
  Azkar('اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ', 'O Allah, send blessings upon Muhammad'),
  Azkar('حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ', 'Allah is sufficient for us, and He is the best disposer of affairs'),
  Azkar('رَبِّ اغْفِرْ لِي', 'My Lord, forgive me'),
  Azkar('اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ', 'O Allah, You are Peace and from You comes peace'),
  Azkar('سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
      'Glory be to Allah, praise be to Allah, there is no god but Allah, and Allah is the Greatest'),
  Azkar('رَضِيتُ بِاللَّهِ رَبًّا وَبِالْإِسْلَامِ دِينًا وَبِمُحَمَّدٍ نَبِيًّا',
      'I am pleased with Allah as my Lord, Islam as my religion, and Muhammad as my Prophet'),
  Azkar('اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ', 'O Allah, I ask You for well-being'),
  Azkar('يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ', 'O Ever-Living, O Sustainer, by Your mercy I seek help'),
  Azkar('اللَّهُمَّ اهْدِنِي وَسَدِّدْنِي', 'O Allah, guide me and make me steadfast'),
  Azkar('رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      'Our Lord, give us good in this world and good in the hereafter, and protect us from the punishment of the Fire'),
  Azkar('اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ', 'O Allah, I seek refuge in You from anxiety and grief'),
  Azkar('سُبْحَانَ الْمَلِكِ الْقُدُّوسِ', 'Glory be to the Sovereign, the Most Holy'),
  Azkar('اللَّهُمَّ لَكَ الْحَمْدُ كَمَا يَنْبَغِي لِجَلَالِ وَجْهِكَ وَعَظِيمِ سُلْطَانِكَ',
      'O Allah, to You belongs praise as befits the majesty of Your Face and the greatness of Your dominion'),
  Azkar('لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      'There is no god but You, glory be to You, indeed I was among the wrongdoers'),
  Azkar('وَتَوَكَّلْ عَلَى اللَّهِ وَكَفَى بِاللَّهِ وَكِيلًا', 'Put your trust in Allah, and Allah is sufficient as a Disposer of affairs'),
  Azkar('اللَّهُمَّ بَارِكْ لَنَا فِيمَا رَزَقْتَنَا', 'O Allah, bless what You have provided for us'),
  Azkar('رَبِّ زِدْنِي عِلْمًا', 'My Lord, increase me in knowledge'),
  Azkar('اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي', 'O Allah, You are Pardoning and love to pardon, so pardon me'),
];
