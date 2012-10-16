Phonetischer Algorithmus nach dem Kölner Verfahren
==================================================

Implementationen
----------------


- **Oracle PL/SQL**: `x3m_soundex_ger.sql`

- **PHP**: `x3m_soundex_ger.php`


Einleitung
----------
Die Kölner Phonetik (auch Kölner Verfahren) ist ein phonetischer Algorithmus, der Wörtern nach ihrem Sprachklang eine Zeichenfolge zuordnet, den phonetischen Code. Ziel dieses Verfahrens ist es, gleich klingenden Wörtern den selben Code zuzuordnen, um bei Suchfunktionen eine Ähnlichkeitssuche zu implementieren. Damit ist es beispielsweise möglich, in einer Namensliste Einträge wie "Meier" auch unter anderen Schreibweisen, wie "Maier", "Mayer" oder "Mayr", zu finden.

Die Kölner Phonetik ist, im Vergleich zum bekannteren Russell-Soundex-Verfahren, besser auf die deutsche Sprache abgestimmt. Sie wurde 1969 von Postel veröffentlicht. 




Algorithmus
-----------

Die Kölner Phonetik bildet jeden Buchstaben eines Wortes auf eine Ziffer
 zwischen "0" und "8" ab, wobei für die Auswahl der jeweiligen Ziffer 
maximal ein benachbarter Buchstabe als Kontext benutzt wird. Einige 
Regeln gelten speziell für den Wortanfang (Anlaut). Auf diese Weise wird
 ähnlichen Lauten derselbe Code zugeordnet. Die beiden Buchstaben "W" 
und "V" beispielsweise werden mit der Ziffer "3" codiert. Der 
phonetische Code für "Wikipedia" lautet "3412". Im Gegensatz zum 
Soundex-Code ist die Länge des phonetischen Codes nach der Kölner 
Phonetik nicht beschränkt.

Buchstabe | Kontext | Code
--------- | ------- | ----
A, E, I, J, O, U, Y | | 0
H | | -
B| | 1
P | nicht vor H | 1
D, T | nicht vor C, S, Z | 2
F, V, W | | 3
P | vor H | 3
G, K, Q | | 4
C | im Anlaut vor A, H, K, L, O, Q, R, U, X | 4
C | vor A, H, K, O, Q, U, X außer nach S, Z | 4
X | nicht nach C, K, Q | 48
L |  | 5
M, N |  | 6
R |  | 7
S, Z |  | 8
C | nach S, Z | 8
C | im Anlaut außer vor A, H, K, L, O, Q, R, U, X | 8
C | nicht vor A, H, K, O, Q, U, X | 8
D, T | vor C, S, Z | 8
X | nach C, K, Q | 8


Dass für den Buchstaben "C" die Regel "<em>S</em>C" Vorrang vor der Regel "C<em>H</em>"
 hat, wurde durch den Zusatz "außer nach S, Z" in Zeile 10 der Tabelle 
berücksichtigt. Dies wird in der Originalveröffentlichung zwar nicht 
explizit erwähnt, kann aber aus den dort angeführten Beispielen 
geschlossen werden (z. B. für "Breschnew" wird als Code "17863" 
angegeben).


Die Umwandlung eines Wortes erfolgt in 3 Schritten:

<ol>
<li>Buchstabenweise Kodierung von links nach rechts entsprechend der Umwandlungstabelle.</li>
<li>Entfernen aller mehrfachen Codes.</li>
<li>Entfernen aller Codes "0" außer am Anfang.</li>
</ol>

###Beispiel
Der Name "Müller-Lüdenscheidt" wird folgendermaßen kodiert:

<ol>
<li>Buchstabenweise Kodierung: 60550750206880022</li>
<li>Entfernen aller mehrfachen Codes: 6050750206802</li>
<li>Entfernen aller Codes "0": 65752682</li>
</ol>

Code Beispiele
--------------
###PHP
```php
require_once 'x3m_soundex_ger.php';
$phoneticcode = soundex_ger("Meier");
```

###Oracle PL/SQL

#####Funktion: SOUNDEX_GER()


```sql
Select SOUNDEX_GER('Meier'), SOUNDEX_GER('Meyer') from Dual
```

#####Funktion: SOUNDEX\_GER_MW()

Die Funktion **SOUNDEX\_GER_MW()** dient als Multi-Word-Wrapper von **SOUNDEX_GER()**. d.h. Die Funktion bricht den Eingabe-String in einzelne Worte auf und codiert jedes einzelne Wort mit **SOUNDEX_GER()**.

```sql
Select SOUNDEX_GER_MW('Mueller Luedenscheidt') from Dual
```

> Die Multi-Word-Funktion ist deshalb wichtig, weil auch schon das im Netz üblicherweise dokumentierte Beispiel Müller-Lüdenscheidt eigentlich falsch gewählt ist. Müller-Lüdenscheidt sind 2 Wörter und damit gibt es 2 Anlaute und 2 Auslaute. Bei diesem Beispiel tritt das nicht zu Tage, aber z.B. bei Heinz Classen (im Unterschied zu HeinzClassen, was nämlich normalerweise kodiert würde). Wird "Heinz Classen" mit der üblichen Implementierung kodiert und dabei ignoriert, dass es sich um 2 Wörter handelt, dann entsteht 068586, wobei Z zu 8 und C ebenfalls zu 8 wird und die zweite 8 entfällt. Wird es als zwei Wörter behandelt, dann wird C zu 4 und bleibt erhalten, also 068 4586.
