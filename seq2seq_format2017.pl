#! /usr/bin/perl

use warnings;
use strict;
use Text::CSV;
use Catmandu::Importer::MARC::ALEPHSEQ;
use Catmandu::Exporter::MARC::ALEPHSEQ;
use Catmandu::Fix::Inline::marc_map qw(:all);
use Catmandu::Fix::marc_add as => 'marc_add';


my @prefixarchiv = (
    'Alters- und Fürsorgekasse der Arbeiter und Arbeiterinnen der Bell AG',
    'Anleihen: Sammlung von Emissionsprospekten und Zeitungsausschnitten',
    'Anstalt für Arbeitsvermittlung',
    'Arbeitslosenkasse des Arbeiterbundes Basel',
    'Arbeitslosigkeit in der Basler Seidenbandindustrie, Hilfskomitee bzw. Hilfskommission für die Arbeitslosen der Textilindustrie',
    'Arbeitslosigkeit in der Stadt Basel',
    'Ausstellung "Arbeit der Frau" in der Basler Mustermesse',
    'Internationale Ausstellung für Binnenschiffahrt und Wasserkraftnutzung',
    'Schweizerische Ausstellung für Landwirtschaft, Forstwirtschaft und Fischerei (VI. Schweiz. landwirtschaftliche Ausstellung)',
    'Ausstellung "Land- und Ferienhaus" in der Basler Mustermesse',
    'Bauarbeiterstreik 1905, Initiativ-Komitee zur Unterstützung der Familien der ausgesperrten Bau-Arbeiter',
    'Arbeiter- bzw. Streikbewegung in der Basler Bandindustrie im Winter 1868/69',
    'IMABA, Internationale Briefmarken-Ausstellung 1948',
    'Donau-Gruppe der International Studies Conference',
    'Expertenkommission über Sparmassnahmen im Betrieb der kantonalen Anstalten des Kantons Zürich',
    'Exportforschungsinstitut in Basel (Projekt)',
    'Fürsorgekasse der Seidenbandindustrie',
    'Gesellschaft zu St. Margarethen',
    'Gewerbs-Innung Klein-Laufenburg (Bachgenossenschaft)',
    'Goldwäscher-Familienkasse',
    'Komitee für die Auslandschweizertage der Schweizer Mustermesse',
    'Internationale Kommission des Völkerbundes zur wirtschaftlichen und finanziellen Wiederaufrichtung Österreichs',
    'Kommission für Wirtschaftsfragen des Kantons Basel-Stadt',
    'Krankenlade der Zimmergesellen Basel',
    'Kranken-Unterstützungs-Verein Murg',
    'Kranken- und Sterbekasse der Möbelfabrik Zehnle & Bussinger',
    'Krippe zu St. Alban',
    'Krippe zu St. Leonhard',
    'Lukas-Stiftung der GGG',
    'Schweiz. Referendumskomitee gegen das Bundesgesetz über die Kranken- und Unfallversicherung (1911)',
    'Rheinschiffahrtskammer beider Basel',
    'Sarasin, Krankenkasse W. Sarasin & Co.',
    'Schülertuch-Stiftung der GGG',
    'Schuhmacher-Krankenkasse Basel',
    'Schweizer Rheinschiffahrts-Konvention',
    'Schweizerische Bibliographie für Statistik und Volkswirtschaft (SBSV)',
    'Schweizerische Statistische Gesellschaft, Ausstellung zu ihrer Geschichte',
    'Stiftung Kommission zur Suppenanstalt',
    'Familie Streckeisen-Caesar und Verwandte',
    'Surinam-Stiftung der Gesellschaft zur Beförderung des Guten und Gemeinnützigen',
    'Unterstützungskasse der Feuerwehr des Kantons Basel-Stadt bei Todesfällen',
    'Schweizerische Wohnungsausstellung in der Basler Mustermesse 1930',
    'Fritz-Mangold-Stiftung',
    'Stiftung zur Förderung des Schweizerischen Wirtschaftsarchivs (StSWA)',
    'Schweizerisches Wirtschaftsarchiv',
);

my @prefixfirmenarchiv = (
    'Aktienbrauerei zum Sternenberg, vorm. Gebr. Zeller',
    'A.G. zur Ausbeutung der Patente Mavrogordato',
    'Aktiengesellschaft zur Erstellung billiger Wohnungen',
    'Aktienverein Gerber',
    'J.S. Alioth & Cie.',
    'Appretur & Mechanische Werkstätten vorm. Aug. Vögelin AG',
    'Asiatische Pflanzungs- und Handels-Aktiengesellschaft',
    'Astra, Einkaufsgenossenschaft des Schweizerischen Schuhmacher-Meister-Verbandes',
    'Bachofen, Johann Jakob & Sohn, Seidenbandfabrikation',
    'Basler Bandfabrik vormals Trüdinger & Cons.',
    'Basler Bankierverein',
    'Bank in Basel AG',
    'Banque Suisse et Française',
    'Baugenossenschaft Basel',
    'Bau- und Industriekeramik AG',
    'Nicolaus de Hieronymus Bernoulli & Sohn, Drogerie und Materialwarenhandlung',
    'Bernoulli-Baer, Leonhard de Niklaus, Drogist und Materialwarenhändler',
    'Bernoulli-von der Tann, Willhelm de Leonhard, Kaufmann',
    'Bernoulli, Leonhard de Niklaus (Sohn) und Niklaus de Johann Bernoulli (Vater), Materialwarenhändler bzw. Apotheker',
    'Leonhard Bernoulli, Drogerie und Materialwaren',
    'Bischoff zu St. Alban',
    'Brenner, Emanuel & Cie, Papiermühle',
    'Basler Brodfabrik AG',
    'Bruckner AG, Weisswaren',
    'Caisse d\'Epargne du district de Moutier SA',
    'Basler Brauerei Cardinal',
    'Brauerei zum Warteck AG, vormals B. Füglistaller',
    'Chemische Union AG',
    'Färberei- u Appretur-Gesellschaft, vorm. Alexander Clavel & Fritz Lindenmeyer AG',
    'Basler Cliché-Fabrik AG',
    'Schweiz. Colonisations-Gesellschaft Santa Fé AG',
    'Compagnie des Eaux de Skutari et Kadi-Keui à Bâle',
    'Allgemeiner Consumverein Basel',
    'Allgemeine Creditbank AG',
    'Basler Credit-Gesellschaft',
    'Dampfschiffahrt-Gesellschaft \'Die Adler des Oberrheins\'',
    'Hans Balthasar Burckhardt und Sohn',
    'Dietschy, Faesch & Co., Weine und Spirituosen',
    'Drahtseilbahn Interlaken-Heimwehfluh AG',
    'Basler Drogerie Leonhard Bernoulli & Co., Kommandit-Aktiengesellschaft',
    'Baslerische Droschkenanstalt',
    'Ehinger-Stierlin, Otto, Manufakturwaren en gros',
    'Ei AG, Geflügel- und Eierfarm',
    'Zinstragende Ersparniskasse, Basel',
    'Faesch, Isaak und Hoffmann, Johann Jakob, holländische Handelsagenten auf Curacao',
    'Feller AG',
    'Aktiengesellschaft Florettspinnerei Ringwald AG',
    'Frères Merian',
    'Frey, Thurneysen & Christ, Seidenbandfabrik',
    'Fürstenberger-Passavant Hans-Georg, Wollhandlung',
    'Genossenschaft für Häute- und Fellverwertung Basel',
    'Genossenschaft Schweizerischer Gipsermeister',
    'Gerberei Brombach AG',
    'Gesellschaft für Bandfabrikation AG',
    'Goldene Apotheke BS, GABA',
    'Gougguer, Xavier & Comp., Baumwoll- & Leinenweberei',
    'Gruner AG, Ingenieurunternehmung',
    'Haag-Kraus, Leonhard, Partikular, alt Schmiedemeister',
    'Basler Handelsbank',
    'Handwerker-Bank Basel AG',
    'Hausbrandzentrale, Kohlenverkaufsstelle für Hausbrand und Kleinbetriebe',
    'Stöckli-Fuhrer, Jean, Fahrradteile und Geflechtfabrik',
    'Hypothekenbank in Basel AG',
    'Immobilien-Genossenschaft Basel',
    'Schweizerische Import-Trust AG (SITAG)',
    'Schappe SA',
    'Hotel Jura, Basel',
    'Kaffeehalle zu Schmieden',
    'Keller, Autotransport & Garage AG',
    'Keller-Paravicini, Johann Jakob, Eisenhandlung',
    'Keller-Vonkilch, Johann Jakob, Bierbrauerei und Weinhandlung',
    'Kling, Camille, Bank- und Effektengeschäft',
    'Knoblauch, Emil & August, Kartonfabrik',
    'Koechlin & Söhne, Bandfabrikanten',
    'Schweizerische Kohlen-Genossenschaft',
    'Kohlenkontor Vulcana AG',
    'Kohlenzentrale AG',
    'Buchdruckerei Kohlhepp AG',
    'Schweizerische Konkordatsbanken',
    'Konsumverein Birsfelden',
    'Konsumverein Bremgarten und Umgebung',
    'Kumpf-Krebs, Bettwaren',
    'Leihkasse für den Bezirk Rheinfelden',
    'Lierow, Albert, Druckerei-Lithographie',
    'Linder, Johann Jakob & Cie, Seidenbandfabrikation',
    'Löffel, Wilhelm, Baugeschäft',
    'Basler Löwenbräu AG',
    'Meili-Wahl, August, Alteisenhandel, Fabrikation von Lötfett und -zinn',
    'Meyer, Johann & Sohn, Manufakturwaren',
    'Müller & Hess, Baugeschäft',
    'Edwin Naef, Seidenwarenfabrikations-Geschäft',
    'Nova Margarine- und Speisefettfabriken AG',
    'Oel- & Fettverwertungs AG',
    'Paravicini-Burckhardt, Leonhard, Eisen- und Metallwarenhandlung',
    'Paravicini, Emanuel, Eisengiesserei',
    'Passavant & Cie, Bankgeschäft',
    'Passavant, Gebrüder Johann Ulrich & Leonhard, Seidenzeug-Fabrikation und -Handel',
    'Perrollaz [Gebrüder Jean, Francois und Joseph] und Konsorten, Tuch- und Kurzwarenhandlung',
    'Basler Personenschiffahrtsgesellschaft (Genossenschaft)',
    'Basler Pfandleihanstalt AG',
    'Neue Birstaler Portland-Cement-Fabrik AG',
    'Dietrich Preiswerk & Comp, Seidenbandfabrikation',
    'Ragus AG',
    'Rebsamen & Naegely, Farben und Lacke',
    'Respinger & Co., Drogerie und Materialwaren',
    'Ateliers Reymond Frères & Cie S.A.',
    'Rheinhafen AG',
    'Ryff & Co. AG, Strickwarenfabrik',
    'Salubratapeten-Fabrik',
    'Sarasin & Cie I, Seidenbandfabrikation',
    'Sarasin & Cie II, Bandfabrik',
    'Sarasin Söhne AG, Seidenwarenfabrikation',
    'Schappecordonnetspinnerei St. Jakob AG',
    'Aktien-Gesellschaft Schappe- und Cordonnet-Spinnerei Ryhiner',
    'Schieferwerk Gantenbach',
    'Schlumberger-Zuber, Charles, Drogenhandel en gros und Schlumberger-Ehinger, Amedée',
    'Schmid und Cie, Leinenweberei',
    'Schweighauserische Buchdruckerei',
    'Schweizerische Reederei und Neptun AG',
    'Service de Bateaux à vapeur entre Bâle et Strasbourg, Renouard de Bussierre, Oswald Frères & Comp.',
    'Simonius, Vischer & Co.',
    'Société Immmobilière d\'Algérie SA (Charles Zahn-Sarasin)',
    'Basler Sparkasse',
    'Spar- und Leihkasse Bremgarten AG',
    'Internationale Speditions-Gesellschaft Schneider & Cie. AG',
    'von Speyr & Cie, Bank- und Speditionsgeschäft',
    'Spinnerei Atzenbach',
    'C. Detloff’s Buchhandlung',
    'Steuer & Cie., Tuchgrosshandel',
    'Stoecklin & Co., Papierfabrik',
    'Suter und Suter AG, Architekten',
    'Texas Landgesellschaft in Basel',
    'Thurneysen & Cie, Seidenbandfabrik',
    'Trottet, Edouard, Mercerie & Quincaillerie en gros',
    'Trust Chimique SA, Produits chimiques et pharmaceutiques',
    'Veillard: Gustav Veillard & Cie. AG, Bank-, Geldwechsel- und Effektengeschäft',
    'Vischer, Leonhard & Sohn, Kolonial- und Farbwarenhandlung',
    'Volderauer, Simon & Comp, Spezerei- und Eisenhandlung',
    'Volkstuch AG',
    'Firmen von Martin Metzger: Importagentur Martin Metzger, Velorex AG, LASERon AG',
    'Waeffler & Co, AG, Handel in Baumwollgarnen und Zwirnen',
    'Wagner, Franz & Cie., Indienne-Druckerei',
    'Walz & Eschle, Seifenfabrik',
    'Warenhaus Loeb',
    'Basler Waschanstalt AG',
    'Schweizerische Wechsel- & Effektenbank AG',
    'Wolle & Seide AG',
    'Würgler & Cie, Zigarrenfabrik',
    'Weis-Leissler, Markus und Nachfolger (Württembergerhof)',
    'Forcart-Weis & Söhne (Württembergerhof)',
    'Burckhardt-Wildt & Sohn (Württembergerhof)',
    'Forcart-Weis und Burckhardt-Wildt (Württembergerhof)',
    'Burckhardt & Co, Seidenbandfabrikation (Württembergerhof)',
    'Zahn & Cie, Bankgeschäft',
    'Zentral-Waschanstalt AG',
    'Zimmerlin, Forcart & Cie, Florettseiden-Spinnerei',
    'Ingenium AG',
    'G. Kiefer & Cie. AG',
    'Heberlein & Co. AG',
    'Hofstetter AG Möbelwerkstätten',
    'Württembergerhof',
    'Firmenarchiv Alusuisse',
    'Dr. Peter Schürch, Seeland Apotheke (Biel)',
    'Rumpf\'sche Kreppweberei AG (Immobiliengesellschaft Weidengasse 49 AG ab 1959)',
);

my @prefixpersonenarchiv = (
    'Wengen-Meyenrock, Fanny Rosalie à, Witwe, Rentière',
    'Bauer, Stephan, Prof. Dr. jur.',
    'Bernoulli-Burckhardt, Niklaus de Johann, Materialwarenhändler und Apotheker',
    'Bernoulli-Baer, Elisabeth',
    'Bernoulli, Johann de Leonhard, Partikular',
    'Beugger, Johann Alexander',
    'Bischoff-Buxtorf, Johannes, Bandfabrikant',
    'Bon, Primus, Wirt, Pächter des Bahnhofrestaurants Zürich-Hauptbahnhof',
    'Bopp, Johann Jakob, Müller',
    'Brüderlin-Rächer, Karl, Wirt',
    'Bührer, Gebrüder',
    'Bullinger-Usteri, Balthasar Gottfried, Friedensrichter und Bertha Schulthess-Bullinger',
    'Burckhardt-Bischoff, Adolf, Dr. h.c., Wirtschaftspolitiker und Bankier',
    'Burckhardt-Burckhardt, Rudolf, Dr. med.',
    'Burckhardt-Forcart, Daniel und Ludwig',
    'Burckhardt-Iselin, Rosine',
    'Burckhardt-Keller, Johann Jakob, Deputat',
    'Burckhardt-Merian, Julius, Kaufmann',
    'Burckhardt-Sarasin, Carl, Dr. h.c., Seidenbandfabrikant',
    'Burckhardt-Vischer, Carl Felix Wilhelm, Bankier',
    'Burckhardt-Vischer, Karl, Rentier',
    'Burckhardt-Vischer, Sophie',
    'Burckhardt-Wildt, Daniel, Bandfabrikant',
    'Buri, Laurenz, Julius und Emil, Marchand-Tailleurs',
    'Burkhard-Wuhrmann Werner, Delegierter der Zolltarif-Kommission',
    'Christen, Erwin, Ingenieur',
    'Christen, Jakob, Ingenieur',
    'Egli, Johann Jakob, Tailleur',
    'Eglinger, Joh. Jakob',
    'Sarasin-Iselin, Alfred, Dr. h.c., Bankier',
    'Escher, Johannes und Escher-Landolt, Anna Barbara',
    'Faesch, Joh. Rudolf, Bürgermeister von Basel',
    'Faesch-Vinet, Johannes von Johannes, Rentner, Privatbankier',
    'Falckner-Birr, Emanuel, Bürgermeister der Stadt Basel',
    'Finckenstein, Dr. Hans Wolfram, Graf von, Vermala sur Sierre',
    'Forcart-Merian, Dietrich, Seidenbandfabrikant',
    'Forcart-Merian, Carl Wilhelm (-von Speyr)',
    'Friedmann, Fritz, Leiter der Reklame-Centrale der Rheinbrücke, Publizist',
    'Frischmann, Daniel, Geschäftsmann',
    'Geering-Schliephacke, Hermine',
    'Geering, Traugott (1859-1932)',
    'Gérault, H., Paris, Fournisseur des Principales Maisons de Banque, Chemin de Fer, Administration et Commerce',
    'Gerber, Adolphe Louis, Strohhutfabrikant',
    'Geigy-Merian, Johann Rudolf, Farbwaren- und Drogenfabrikant',
    'Goetzen-Sarasin, Anna von, Landwirtin',
    'Grimm, Johann Karl, Ratsherr und Bürgermeister',
    'Gubler, Robert, Dr. med, Bezirksarzt',
    'Künzel-Kressler, Jakob, Architekt, Basel',
    'Heuberger-Stoll, Emil, Wagnermeister',
    'Hildenbrand, Vinzenz Jakob',
    'Hoffmann, Emanuel, Seidenbandfabrikant',
    'Hoffmann, Goenner & Cie, Tuchgeschäft',
    'Hörler-Krug, Anna Maria, Partikularin',
    'Huber-Rohner, Johann Jakob, Prof. der Astronomie',
    'Iffenthaler-Mohler, Ludwig, Kanzleisekretär',
    'Iselin-Weis (Falkner), Daniel',
    'Jenny-Rosenmund, Oskar Hugo, Dr. phil. Kantonsstatistiker',
    'Wolf, Benjamin (vormals Wolff, Felix) und Wolf, Bernhard',
    'Keller-Göttisheim, Marie, Ehefrau des Franz Hermann Keller-Göttisheim, Dr. med, Kurarzt in Rheinfelden',
    'Kern-His, Eduard, Dr. jur., Notar',
    'Kinkelin, Hermann, Prof. Dr., Mathematiker und Politiker',
    'König, Magdalena, Damenschneiderin und Putzmacherin und Zimmermann-König, Johannes, Handelsmann',
    'Krug, Johannes (1795-1866)',
    'Landmann, Julius, Prof. Dr. phil., Nationalökonom',
    'LeGrand-Heusler, Johannes und Familie',
    'Lendorff-Berri, Karl, Architekt',
    'Linder, Johann Jakob, Mannenschneider',
    'Linder-Preiswerk, Hans',
    'Lutz, Johannes, Wirt zum Engel',
    'Maeglin, Benoît',
    'Mangold-Müller, Friedrich, Regierungsrat, Prof. für Statistik, Vorsitzender SWA',
    'Margreth-Geering, Elisabeth',
    'Menzi, Elsa, Laborantin',
    'Merian-Burckhardt, Sophia',
    'Merian-Burckhardt, Christoph',
    'Merian-Hoffmann, Christoph',
    'Merian-Werthemann, Susanne',
    'Meyer, Diethelm, Pfarrer und Dekan',
    'Meyer, Emanuel Walter, Partikular',
    'Mez, John Richard, Prof. der Nationalökonomie',
    'Moerikofer-Widmer, Peter Paul, Kaufmann, stv. Börsenkommissar',
    'Moppert-Burckhardt, Esther',
    'Oeschy, Joseph',
    'Pack-Mosis, Jakob Christoph, Steinmetzmeister und Zimmermann',
    'Paganini, Robert, Dr. Chemiker, Treuhänder',
    'Poeppig, Eduard Friedrich',
    'Portmann, Melchior, Müllermeister, Klingentalmühle',
    'Preiswerk-Forcart, Lucas, Bandfabrikant',
    'Raecher, Friedrich',
    'Rahm-Waser, Emil, Dr. med.',
    'Rosenlächer-Gubelmann, Joseph, Glockengiesser',
    'Ryhiner-Christ, Emanuel, Rentier',
    'Sarasin-Forcart, Esther Emilie (1807-1866)',
    'Sarasin, Johann von Johann Lukas / Burckhardt-Brek, Elie, J.U.D.',
    'Schmidlin-Von der Mühll, Wilhelm, Baumeister',
    'Schneider, Salome, Dr. phil, Privat-Dozentin und Bibliothekarin',
    'Schönauer-Bernoulli, Daniel, Handelsmann',
    'Scholtz, Caspar (1594-1615) und Jacob (1596-?)',
    'Seiz, Wilhelm, Secrétaire-inspecteur de la Société suisse des chefs d\'atelier décorateurs',
    'Haag, Friedrich, Schmiedemeister und Siegrist, Emil, Wagnermeister',
    'Simonius-Blumer, Alfons (Vater), Cellulosefabrikant Simonius-Vischer, Paul (Sohn), Dipl. Ing. ETH,',
    'Speiser-Sarasin, Paul, Prof. Dr. jur.',
    'Speiser-Strohl, William, Direktor der Eisenbahnbank',
    'Stähelin-Passavant, Hieronymus, Eisenhändler',
    'Straumann-Gamper, Friedrich Heinrich, Spenglermeister',
    'Streckeisen-Schaub, Mathias',
    'Streckeisen-Caesar, Emanuel, Kaufmann und Bankier',
    'Stünzi (Familie), Käpfnach bei Horgen',
    'Sulger-Staehelin, Andreas und Marie, Direktor Schweizerische Centralbahn',
    'Taur, Friedrich, Herausgeber und Redaktor der Schweizerischen Eisenbahn- und Handelszeitung',
    'Familie Vischer-Burckhardt, Peter, Bandfabrikant',
    'Vischer-Preiswerk, Sophia',
    'Weber-Weber, Adolf, Ingenieur',
    'Weiss, Frank, Dr., Vorsteher der Ausgleichskasse Basel',
    'Forcart-Iselin, Achilles (1777-1884)',
    'Wyss, Ulrich, Gemeindeschreiber',
    'Ziegler, Bernhartin, Haus zum Löwenkopf',
    'Stalder-Spiess, W.H., Bankdirektor',
    'Egli, Gustav, Dr., Generalsekretär Landesverband Freier Schweizer Arbeiter',
    'Leuthold, Laurance',
    'Fellmann-Keller, Paul',
    'Tietz, Bruno, Prof. Dr.',
    'Bombach, Gottfried, Prof. Dr. (1919-2010)',
);

my @prefixteilarchiv = (
    'Bürgerspital Basel',
    'Forstverwaltung der Bürgergemeinde Basel',
    'Gesellschaft zur Beförderung des Guten und Gemeinnützigen (GGG)',
    'Knie, Gebrüder, Schweizer National-Zirkus',
    'Psychiatrische Universitätsklinik Friedmatt',
    'Standard Telephon und Radio AG (STR)',
    'Zwilchenbart AG, Auswanderungs- und Passageagentur, Reisebureau',
);

my @prefixverbandsarchiv = (
    'Basler Vereinigung zur Förderung des Luftverkehrs (BVFL)',
    'Basler Bandfabrikanten-Verein',
    'Bandpropaganda-Comité des Basler Bandfabrikanten-Vereins',
    'Banksektion des Basler Handels- und Industrievereins',
    'Bildhauerverein Basel',
    'Bruderschaft der Schuhmacher in Basel',
    'Schweizerischer Coiffeurmeister-Verband',
    'Basler Gartenbau-Gesellschaft',
    'Genossenschaft der Seidenbandweber von Baselland und Umgebung',
    'Genossenschaft zur Förderung des Schweizerisch-Ungarischen Warenverkehrs, GESUWA',
    'Gesellschaft des katholischen Vereinshauses \'Basler Hof\'',
    'Basler Gesellschaft für Seidenindustrie',
    'Schweizerische Gesellschaft für Statistik und Volkswirtschaft',
    'Statistisch-Volkswirtschaftliche Gesellschaft Basel',
    'Gewerkschaft der Erd- und Tiefbauarbeiter, Sektion des Arbeiterbundes Basel',
    'Schweizerischer Grossisten-Verband',
    'Handels- und Industrie-Verein in Basel',
    'Brennstoffhändler-Verband der Nordwestschweiz',
    'Importvereinigung der Engros-Firmen der Mercerie, Bonneterie- und Kurzwaren-Branchen (I.M.B.)',
    'Interessenverband Schweizerischer Grossisten',
    'Schweizerisches Komitee für Chemie',
    'Schweizerisches Komitee für Weltwirtschaft (SKW)',
    'Internationaler Metallarbeiterbund IMB, Fédération internationale des ouvriers sur métaux',
    'Sammlerschutzstelle des Verbandes Schweizerischer Philatelisten-Vereine',
    'Posamenter-Verband Baselland (alter Verband)',
    'Schmiede- und Wagner-Fachverein von Basel und Umgebung',
    'Schuhmachermeister-Verein Basel',
    'Schweizerischer Arbeiter-Verein',
    'Schweizerische Vereinigung für Dokumentation (SVD)',
    'Schweizerischer Seidenbandfabrikanten-Verein',
    'Staatsarbeiter-Verein Basel',
    'Schweizerischer Strassenbahner-Verband, Sektion Basel',
    'Syndikat der schweizerischen Bandfabrikanten',
    'Verband der Angestellten und Arbeiter des Kantons Basel-Stadt',
    'Verband der Arbeiter und Arbeitgeber der Basler Bandfabriken (VAB)',
    'Verband Basler Detaillisten',
    'Verband Basler Goldschmiede',
    'Verband oberrheinischer Bandfabrikanten (VOB)',
    'Verband Schweizerischer Drahtgeflecht-Fabrikanten',
    'Verband schweizerischer Roskopfuhren-Industrieller',
    'Verband Schweizerischer Transit- und Welthandelsfirmen',
    'Schweizerischer Verband für Wohnungswesen und Wohnungsreform',
    'Verband Schweizerischer Dampf- und Motorwäschereien',
    'Verein der Arbeiter des Gas-, Wasser- und Elektrizitätswerks Basel',
    'Verein der Basler Staatsangestellten',
    'Verein der Basler Strassenbahner',
    'Verein für Hauspflege in der Münster- und St. Elisabethengemeinde Basel',
    'Verein für Mässigkeit und Volkswohl',
    'Vereinigung der Walzstahlverarbeiter, Schweizerische',
    'Internationale Vereinigung für gesetzlichen Arbeiterschutz',
    'Basler Vereinigung für industrielle Landwirtschaft und Innenkolonisation',
    'Vereinigung zur Anstrebung einer Gotthardbahn',
    'Schweizerische Vereinigung zur Förderung des internationalen Arbeiterschutzes, Sektion Basel',
    'Basler Volkswirtschaftsbund',
    'Vereinigung Basler Ökonomen',
    'Verband Schweizerischer Zollangestellter (Sektion Basel)',
    'Schweizerischer Laborpersonalverband (SLV)',
);

my @digitalisate = (
    '000066692 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=169227.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Aufführungsmaterial / Zuspielaufnahme, Version ohne Coda (Schweizer Nationalphonotek Lugano)',
    '000066692 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=169228.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme, Version mit Coda (Schweizer Nationalphonotek Lugano)',
    '000066841 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178995.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme (Schweizer Nationalphonotek Lugano)',
    '000066867 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=169257.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Aufführungsmaterial (Schweizer Nationalphonotek Lugano, Signatur: 26BD536)',
    '000066867 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=169252.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Aufführungsmaterial, (Schweizer Nationalphonotek Lugano, Signatur: 18BD1888)',
    '000066867 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=179027.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Konzertaufzeichnung (Schweizer Nationalphonotek Lugano)',
    '000066970 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=169036.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme (Schweizer Nationalphonotek Lugano)',
    '000067198 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=179027.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Konzertaufzeichnung (Schweizer Nationalphonotek Lugano)',
    '000067478 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178943.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme, längere Version (Schweizer Nationalphonotek Lugano)',
    '000067478 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178947.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme, kürzere Version (Schweizer Nationalphonotek Lugano)',
    '000068307 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=179027.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Konzertaufzeichnung (Schweizer Nationalphonotek Lugano)',
    '000068609 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=179027.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Konzertaufzeichnung (Schweizer Nationalphonotek Lugano)',
    '000068610 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=179020.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme (Schweizer Nationalphonotek Lugano)',
    '000068710 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=179027.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Konzertaufzeichnung (Schweizer Nationalphonotek Lugano)',
    '000068734 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=179007.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme (Schweizer Nationalphonotek Lugano)',
    '000068734 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=179016.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Studioaufzeichnung (Schweizer Nationalphonotek Lugano)',
    '000068734 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=179027.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Konzertaufzeichnung (Schweizer Nationalphonotek Lugano)',
    '000068750 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178981.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme (Schweizer Nationalphonotek Lugano)',
    '000068750 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178982.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Konzertaufzeichnung (Schweizer Nationalphonotek Lugano)',
    '000068852 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=169229.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme (Schweizer Nationalphonotek Lugano)',
    '000068852 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=179027.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Konzertaufzeichnung (Schweizer Nationalphonotek Lugano)',
    '000068854 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=169218.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme (Schweizer Nationalphonotek Lugano)',
    '000068895 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178924.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme (Schweizer Nationalphonotek Lugano)',
    '000068895 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178935.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Konzertaufzeichnung (Schweizer Nationalphonotek Lugano)',
    '000068903 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=169081.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Konzertaufzeichnung (Schweizer Nationalphonotek Lugano)',
    '000068903 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=169080.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme, Version mit Coda & Codetta (Schweizer Nationalphonotek Lugano)',
    '000068903 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=169068.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme, Version ohne Coda (Schweizer Nationalphonotek Lugano)',
    '000068903 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=169074.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme, Version mit Coda (Schweizer Nationalphonotek Lugano)',
    '000068907 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=169246.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Aufführungsmaterial (Schweizer Nationalphonotek Lugano)',
    '000068907 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=169250.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme (Schweizer Nationalphonotek Lugano)',
    '000068911 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178997.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme (Schweizer Nationalphonotek Lugano)',
    '000068912 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=182280.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Aufführungsmaterial, kürzere Version (Schweizer Nationalphonotek Lugano)',
    '000068912 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=169148.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Aufführungsmaterial, längere Version (Schweizer Nationalphonotek Lugano).',
    '000068945 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=179027.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Konzertaufzeichnung (Schweizer Nationalphonotek Lugano)',
    '000069078 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178954.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme, 1. Version (Schweizer Nationalphonotek Lugano)',
    '000069078 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178959.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme, 2. Version (Schweizer Nationalphonotek Lugano)',
    '000069567 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178907.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Aufführungsmaterial, Version ohne Coda (Schweizer Nationalphonotek Lugano)',
    '000069567 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178910.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Aufführungsmaterial, Version mit Coda (Schweizer Nationalphonotek Lugano)',
    '000069602 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=169259.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme (Schweizer Nationalphonotek Lugano)',
    '000069604 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178914.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Aufführungsmaterial (Schweizer Nationalphonotek Lugano)',
    '000069605 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178920.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Aufführungsmaterial (Schweizer Nationalphonotek Lugano)',
    '000069618 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=179001.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Aufführungsmaterial (Schweizer Nationalphonotek Lugano)',
    '000070719 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178963.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme (Schweizer Nationalphonotek Lugano, Archiv-Nr.: 18BD1895)',
    '000070719 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178968.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme (Schweizer Nationalphonotek Lugano, Archiv-Nr.: 26BD527)',
    '000071981 856   L $$uhttp://ntvmr.uni-muenster.de/manuscript-workspace/?docID=30001$$zInstitut für neutestamentliche Textforschung, Münster (Digitalisat)',
    '000072556 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=169142.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme (Schweizer Nationalphonotek Lugano)',
    '000075736 856   L $$uhttp://www.fonoteca.ch/cgi-bin/oecgi3.exe/inet_fnbasefondsdetail?REC_ID=178951.011&LNG_ID=DEU$$zDigitale Archivkopie des Magnetbands mit Zuspielaufnahme, Zuordnung unsicher (Schweizer Nationalphonotek Lugano)',
    '000079136 856   L $$uhttp://www.e-codices.unifr.ch/de/searchresult/list/one/ubb/B-IV-0011$$zDigitalisat auf e-codices',
    '000079166 856   L $$uhttp://bibliotheca-laureshamensis-digital.de/view/ubb_bv13$$zBibliotheca Laureshamensis digital (Digitalisat)',
    '000079168 856   L $$uhttp://bibliotheca-laureshamensis-digital.de/view/ubb_bv14$$zBibliotheca Laureshamensis digital (Digitalisat)',
    '000084198 856   L $$uhttp://www.basler-fruehdrucke.ch/resources/4483$$zBilderfolgen Basler Frühdrucke',
    '000084910 856   L $$uhttp://www.basler-fruehdrucke.ch/resources/4678$$zBilderfolgen Basler Frühdrucke',
    '000100682 856   L $$uhttp://www.gosteli-foundation.ch/shared/files/agof-180-556-602-09.pdf$$zVolltext (PDF)',
    '000109831 856   L $$uhttp://ntvmr.uni-muenster.de/manuscript-workspace/?docID=30092$$zInstitut für neutestamentliche Textforschung, Münster (Digitalisat)',
    '000117051 856   L $$uhttp://nausikaa2.mpiwg-berlin.mpg.de/cgi-bin/toc/toc.test.cgi?dir=ZEMHAEZ8;step=thumb$$zDigitalisierter Mikrofilm',
    '000164167 856   L $$uhttp://ntvmr.uni-muenster.de/manuscript-workspace/?docID=32817$$zInstitut für neutestamentliche Textforschung, Münster (Digitalisat)',
    '000164168 856   L $$uhttp://ntvmr.uni-muenster.de/manuscript-workspace/?docID=20007$$zInstitut für neutestamentliche Textforschung, Münster (Digitalisat, ohne 97v und 248r)',
    '000164168 856   L $$uhttp://ntvmr.uni-muenster.de/manuscript-workspace/?docID=32087$$zInstitut für neutestamentliche Textforschung, Münster (Digitalisat von 97v und 248r)',
    '000164169 856   L $$uhttp://ntvmr.uni-muenster.de/manuscript-workspace/?docID=30002$$zInstitut für neutestamentliche Textforschung, Münster (Digitalisat)',
    '000164171 856   L $$uhttp://ntvmr.uni-muenster.de/manuscript-workspace/?docID=32816$$zInstitut für neutestamentliche Textforschung, Münster (Digitalisat)',
    '000166317 856   L $$uhttp://www.e-codices.unifr.ch/de/list/one/vad/0298$$zDigitales Vollfaksimile in e-codices',
    '000170460 856   L $$uhttp://bibliotheca-laureshamensis-digital.de/view/zbso_s716$$zBibliotheca laureshamensis (Digitalisat, Beschreibung)',
    '000174114 856   L $$uhttp://www.e-codices.unifr.ch/de/description/zbs/S-0194$$zE-codices. Digitalisat und Beschreibung',
    '000174164 856   L $$uhttp://www.e-codices.unifr.ch/de/list/one/zbs/SII-0043$$zE-codices; Volldigitalisat mit Beschreibung',
    '000178268 856   L $$uhttp://www.e-codices.unifr.ch/de/description/zbs/S-0378$$zDigitalisat auf e-codices',
    '000178702 856   L $$uhttp://www.e-codices.unifr.ch/de/list/one/zbs/S-0386$$zE-codices, Volldigitalisat mit Beschreibung',
    '000180667 856   L $$uhttp://www.e-codices.unifr.ch/de/list/one/zbs/S-0451$$zE-codices',
    '000193357 856   L $$uhttp://bibliotheca-laureshamensis-digital.de/view/ubb_nI3no13_15$$zBibliotheca Laureshamensis digital (Digitalisat)',
    '000196911 856   L $$uhttp://www.e-codices.unifr.ch/de/list/one/zbs/SI-0175$$zE-codices (Volldigitalisat mit Beschreibung)',
    '000197180 856   L $$uhttp://www.e-codices.unifr.ch/de/zbs/SI-0167$$zE-codices, Volldigitalisat, Beschreibung',
    '000206902 856   L $$uhttp://freimore.uni-freiburg.de/receive/DocPortal_document_00010697$$zHandschriften der lateinischen Werke des Raimundus Lullus, Raimundus- Lullus-Institut, Freiburg (Beschreibung und Teildigitalisat)',
    '000211624 856   L $$uhttp://digital.staatsbibliothek-berlin.de/werkansicht/?PPN=PPN77826064X$$zStaatsbibliothek Berlin (Digitalisat)',
    '000263891 856   L $$uhttp://aleph.sg.ch/F/?/&func=find-b&find_code=SYS&request=001290146$$zBildnachlass Albin Grau (mit Digitalisaten)',
    '000263895 856   L $$uhttp://aleph.sg.ch/F/?/&func=find-b&find_code=SYS&request=001290146$$zBildnachlass Albin Grau (mit Digitalisaten)',
    '000265396 856   L $$uhttp://www.e-codices.unifr.ch/de/list/one/csg/0761$$ze-codeices (Digitalisat)',
    '000297155 856   L $$zhttp://www.e-codices.unifr.ch/de/list/one/csg/0464$$ue-codices (Digitalisat)',
);

my @bernoullichange = (
    '000227937',
    '000233863',
    '000265385',
    '000234476',
    '000270599',
    '000278517',
    '000287406',
    '000283342',
);

die "Argumente: $0 Input Output Bernoulli-csv\n" unless @ARGV == 3;

my($inputfile,$outputfile,$bernoullicsv) = @ARGV;
my $tempfile = './temp.seq';

my $csv = Text::CSV->new({ sep_char => ',' });

open(my $csvdata, '<:encoding(utf8)', $bernoullicsv) or die "Could not open '$bernoullicsv' $!\n";
my @b001;
my %b773t;
my %b773g;
my %b773j;
my %b773w;

while (my $line = <$csvdata>) {
    chomp $line;

    if ($csv->parse($line)) {

        my @fields = $csv->fields();
        my $sys = $fields[0];
        push @b001, $sys;
        $b773w{$sys} = $fields[1];
        $b773t{$sys} = $fields[2];
        $b773g{$sys} = $fields[3];
        $b773j{$sys} = $fields[4];
    } else {
        warn "Line could not be parsed: $line\n";
    }
}



open my $in, "<", $inputfile or die "$0: open $inputfile: $!";
open my $out, ">", $tempfile or die "$0: open $tempfile: $!";

my $f008pos6;

NEWLINE: while (<$in>) {
    my $sysnumber = (substr $_ , 0, 9);
    my $line = $_;
    my $field = (substr $line, 10, 3);
    my $ind1 = (substr $line, 13, 1);
    my $ind2 = (substr $line, 14, 1);
    my $content = (substr $line, 18);
    chomp $line;
    chomp $content;

    my @subfields = split(/\$\$/, $line);
    shift @subfields;

    # Wir gehen hier davon aus, dass Feld 008 immer vor Feld 593 vorkommt - sonst haben wir ein Problem
    if ($field =~ /008/) {
        $f008pos6 = substr($line,24,1);
    }

	if ($field =~ /090/) {
	    my $delete090 = 1;
	    foreach (@subfields) {
                if (substr($_,0,1) eq 'b') {
	            $delete090 = 0
	        }
	    }
	    if ($delete090) {
                next NEWLINE
	    }
	}

    if ($field =~ /245/) {
        foreach (@prefixarchiv) {
            $line =~ s/\$\$a\Q$_\E/\$\$aArchiv $_/g
        }
        foreach (@prefixteilarchiv) {
            $line =~ s/\$\$a\Q$_\E/\$\$aTeilachiv $_/g
        }
        foreach (@prefixpersonenarchiv) {
            $line =~ s/\$\$a\Q$_\E/\$\$aPersonenarchiv $_/g
        }
        foreach (@prefixfirmenarchiv) {
            $line =~ s/\$\$a\Q$_\E/\$\$aFirmenarchiv $_/g
        }
        foreach (@prefixverbandsarchiv) {
            $line =~ s/\$\$a\Q$_\E/\$\$aVerbandsarchiv $_/g
        }
    }

    if ($field =~ /246/) {
        if ($ind1 =~ /2/) {
            next NEWLINE
        } else {
            $line = $sysnumber . ' 2463  L ' . $content;
        }
    }

    if ($field =~ /490/) {
        foreach (@prefixarchiv) {
            $line =~ s/\$\$a\Q$_\E/\$\$aArchiv $_/g
        }
        foreach (@prefixteilarchiv) {
            $line =~ s/\$\$a\Q$_\E/\$\$aTeilarchiv $_/g
        }
        foreach (@prefixpersonenarchiv) {
           $line =~ s/\$\$a\Q$_\E/\$\$aPersonenarchiv $_/g
        }
        foreach (@prefixfirmenarchiv) {
            $line =~ s/\$\$a\Q$_\E/\$\$aFirmenarchiv $_/g
        }
        foreach (@prefixverbandsarchiv) {
            $line =~ s/\$\$a\Q$_\E/\$\$aVerbandsarchiv $_/g
        }

        my $f490a;
        my $f490i;
        my $f490v;
        my $f490w;

        foreach (@subfields) {
            if (substr($_,0,1) eq 'a')  {
                $f490a = substr($_,1)
            }
            if (substr($_,0,1) eq 'i')  {
                $f490i = substr($_,1)
            }
            if (substr($_,0,1) eq 'v')  {
                $f490v = substr($_,1)
            }
            if (substr($_,0,1) eq 'w')  {
                $f490w = substr($_,1)
            }
        }

        $f490w = sprintf("%09d", $f490w);

        foreach (@bernoullichange) {
            if ($_ =~ /$f490w/ ) {
                $line = $sysnumber . ' 773 A L $$g' . $f490v . '$$j' . $f490i . '$$t' . $f490a . '$$w' . $f490w;
            } else {
                $line = $sysnumber . ' 490   L $$a' . $f490a . '$$i' . $f490i . '$$v' . $f490v . '$$w' . $f490w;
                $line =~ s/\$\$i\$\$/\$\$/g;
                $line =~ s/\$\$v\$\$/\$\$/g;
                $line =~ s/\$\$a\$\$/\$\$/g;
                $line =~ s/\$\$w$//g;
                $line =~ s/\$\$w000000000$//g;
            }
        }
    }


    if ($field =~ /500/) {
        if ($ind1 =~ /A/) {
            $line = $sysnumber . ' 525   L ' . $content;
        }
        if ($ind1 =~ /B/) {
            $line = $sysnumber . ' 561   L ' . $content;
        }
        if ($ind1 =~ /O/) {
            $line = $sysnumber . ' 561   L ' . $content;
        }
    }

    if ($field =~ /542/) {
       $line =  $sysnumber . ' 542 0 L ' . $content;
    }

    if ($field =~ /593/) {

        my $f046c;
        my $f046e;

        my $f593 = substr($content,3);
        $f593 =~ s/–/-/g;

        if ($f593 =~ /-/) {
           my @f593 = split /-/, $f593;
            $f046c = $f593[0];
            $f046e = $f593[1];
        } else {
            $f046c = $f593;
        }

        $line = $sysnumber . ' 046   L $$a' . $f008pos6 . '$$c' . $f046c;

        if ($f046e) {
           $line .= '$$e' . $f046e;
        }
    }

    if ($field =~ /909/) {
        if ($ind1 =~ /f/ ) {
            next NEWLINE
        }
        if ($ind1 =~ /M/ ) {
            $line = $sysnumber . ' 254   L $$aStimmen';
        }
        foreach (@subfields) {
            if ((substr($_,0,1) eq 'f') && substr($_,1) eq 'ubmscr') {
                next NEWLINE
            }
        }
    }

    if ($field =~ /773/) {
        my $f773g;
        my $f773j;
        my $f773t;
        my $f773w;

        foreach (@subfields) {
            if (substr($_, 0, 1) eq 'g') {
                $f773g = substr($_, 1)
            }
            if (substr($_, 0, 1) eq 'j') {
                $f773j = substr($_, 1)
            }
            if (substr($_, 0, 1) eq 't') {
                $f773t = substr($_, 1)
            }
            if (substr($_, 0, 1) eq 'w') {
                $f773w = substr($_, 1)
            }
        }

        $f773w = sprintf("%09d", $f773w);

        $line = $sysnumber . ' 773 A L $$g' . $f773g . '$$j' . $f773j . '$$t' . $f773t . '$$w' . $f773w;
        $line =~ s/\$\$g\$\$/\$\$/g;
        $line =~ s/\$\$j\$\$/\$\$/g;
        $line =~ s/\$\$t\$\$/\$\$/g;
        $line =~ s/\$\$w$//g;
        $line =~ s/\$\$w000000000$//g;
    }

    if ($field =~ /852/) {
        my $new773;
        foreach my $sys (@b001) {
            if ($sys == $sysnumber) {
                $new773 = $sysnumber . ' 773 A L $$g' . $b773g{$sys} . '$$j' . $b773j{$sys} . '$$t' . $b773t{$sys} . '$$w' . $b773w{$sys} . "\n";
                $line = $new773 . $line;
            }
        }
    }

    if ($field =~ /856/) {
        my $digitalisat;
        foreach (@subfields) {
            if (substr($_,0,1) eq 'z' && substr($_,1) =~ /^(Digitalisat|e-codices|Brieftext)/) {
                $digitalisat = 1;
            }
        }

        foreach (@digitalisate) {
           if ($line =~ /\Q$_\E/ ) {
                $digitalisat = 1;
            }
        }

        if ($digitalisat) {
             $line = $sysnumber . ' 856 1 L '. $content;
        } else {
             $line = $sysnumber . ' 856 2 L '. $content;
        }

    }


    print $out $line . "\n";
}

close $out or warn "$0: close $tempfile $!";

my $importer = Catmandu::Importer::MARC::ALEPHSEQ->new(file => $tempfile);
my $exporter = Catmandu::Exporter::MARC::ALEPHSEQ->new(file => $outputfile);

$importer->each(sub {
    my $f909collect;
    my $ldrpos17;
    my $f852basel;
    my $f852sig;
    my $f852sigbriefe;
    my $f906briefe = 1;

    my $data = $_[0];

    my $f351c = marc_map($data, '351c',);

    my $ldr = marc_map($data, 'LDR');
    $ldrpos17 = substr($ldr, 17, 1);

    my $f852a = marc_map($data, '852[  ]a',);
    $f852basel = 1 if $f852a =~ /Basel UB$/;

    my $f852p = marc_map($data, '852[  ]p');
    $f852sig = 1 if $f852p =~ /^(H|J |Q|AA|A lambda|AG|AR I)/;
    $f852sig = 0 if $f852p =~ /^(H I|H V 114a|H V 114b|H V 232|H VI|AR II)/;
    $f852sig = 1 if $f852p =~ /^(H II|H IV)/;
    $f852sig = 0 if $f351c =~ /^(Hauptabteilung|Abteilung)/;
    $f852sigbriefe = 1 if $f852p =~ /^(Falk|Frey-Gryn|VB|KiAr)/;
    $f852sigbriefe = 0 if $f351c =~ /^(Hauptabteilung|Abteilung)/;

    print $f852p . ": " . $f852sig . " / ". $f852sigbriefe . "\n";

    my @f906a = marc_map($data, '906a');
    foreach (@f906a) {
        $f906briefe = 0 if $_ =~ /^Briefe/
    }

    my @f909f = marc_map($data, '909f');
    foreach (@f909f) {
        $f909collect = 1 if $_ =~ /collect_this (handschrift|miszellan)/
    }

    if ($f909collect || ( $f852basel && $f852sig ) || ( $f852basel && $f906briefe && $f852sigbriefe)) {
        $data = marc_add($data,'542','ind2','1','l','CC-BY-NC');
    } else {
        $data = marc_add($data,'542','ind2','1','l','CC0');
    }

    if ($f909collect || ( $f852basel && $f852sig ) || ($f852basel && $f852sigbriefe && $f906briefe)) {
       if ($ldrpos17 == 7) {
           $data = marc_add($data,'588','a','Minimalniveau');
       } elsif ($ldrpos17 == 4) {
           $data = marc_add($data,'588','a','Normalniveau');
       } elsif ($ldrpos17 eq 'u')  {
           $data = marc_add($data,'588','a','Kurzeintrag');
       }
    }

    $exporter->add($data);
});

$exporter->commit;
exit;

