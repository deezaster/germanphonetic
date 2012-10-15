
<h1>Phonetischer Algorithmus nach dem Kölner Verfahren</h1>

Die Kölner Phonetik (auch Kölner Verfahren) ist ein phonetischer Algorithmus, der Wörtern nach ihrem Sprachklang eine Zeichenfolge zuordnet, den phonetischen Code. Ziel dieses Verfahrens ist es, gleich klingenden Wörtern den selben Code zuzuordnen, um bei Suchfunktionen eine Ähnlichkeitssuche zu implementieren. Damit ist es beispielsweise möglich, in einer Namensliste Einträge wie "Meier" auch unter anderen Schreibweisen, wie "Maier", "Mayer" oder "Mayr", zu finden.

Die Kölner Phonetik ist, im Vergleich zum bekannteren Russell-Soundex-Verfahren, besser auf die deutsche Sprache abgestimmt. Sie wurde 1969 von Postel veröffentlicht. 




<h2>Algorithmus</h2>

Die Kölner Phonetik bildet jeden Buchstaben eines Wortes auf eine Ziffer
 zwischen "0" und "8" ab, wobei für die Auswahl der jeweiligen Ziffer 
maximal ein benachbarter Buchstabe als Kontext benutzt wird. Einige 
Regeln gelten speziell für den Wortanfang (Anlaut). Auf diese Weise wird
 ähnlichen Lauten derselbe Code zugeordnet. Die beiden Buchstaben "W" 
und "V" beispielsweise werden mit der Ziffer "3" codiert. Der 
phonetische Code für "Wikipedia" lautet "3412". Im Gegensatz zum 
Soundex-Code ist die Länge des phonetischen Codes nach der Kölner 
Phonetik nicht beschränkt.

<table style="width: 550px;">
<thead>
<tr>
<th>Buchstabe</th>
<th>Kontext</th>
<th align="center">Code</th>
</tr>
</thead>
<tbody>
<tr>
<td><strong>A, E, I, J, O, U, Y</strong></td>
<td>&nbsp;</td>
<td align="center">0</td>
</tr>
<tr>
<td><strong>H</strong></td>
<td>&nbsp;</td>
<td align="center">-</td>
</tr>
<tr>
<td><strong>B</strong></td>
<td>&nbsp;</td>
<td align="center" rowspan="2">1</td>
</tr>
<tr>
<td><strong>P</strong></td>
<td>nicht vor H</td>
</tr>
<tr>
<td><strong>D, T</strong></td>
<td>nicht vor C, S, Z</td>
<td align="center">2</td>
</tr>
<tr>
<td><strong>F, V, W</strong></td>
<td>&nbsp;</td>
<td align="center" rowspan="2">3</td>
</tr>
<tr>
<td><strong>P</strong></td>
<td>vor H</td>
</tr>
<tr>
<td><strong>G, K, Q</strong></td>
<td>&nbsp;</td>
<td align="center" rowspan="3">4</td>
</tr>
<tr>
<td rowspan="2"><strong>C</strong></td>
<td>im Anlaut vor A, H, K, L, O, Q, R, U, X</td>
</tr>
<tr>
<td>vor A, H, K, O, Q, U, X außer nach S, Z</td>
</tr>
<tr>
<td><strong>X</strong></td>
<td>nicht nach C, K, Q</td>
<td align="center">48</td>
</tr>
<tr>
<td><strong>L</strong></td>
<td>&nbsp;</td>
<td align="center">5</td>
</tr>
<tr>
<td><strong>M, N</strong></td>
<td>&nbsp;</td>
<td align="center">6</td>
</tr>
<tr>
<td><strong>R</strong></td>
<td>&nbsp;</td>
<td align="center">7</td>
</tr>
<tr>
<td><strong>S, Z</strong></td>
<td>&nbsp;</td>
<td align="center" rowspan="6">8</td>
</tr>
<tr>
<td rowspan="3"><strong>C</strong></td>
<td>nach S, Z</td>
</tr>
<tr>
<td>im Anlaut außer vor A, H, K, L, O, Q, R, U, X</td>
</tr>
<tr>
<td>nicht vor A, H, K, O, Q, U, X</td>
</tr>
<tr>
<td><strong>D, T</strong></td>
<td>vor C, S, Z</td>
</tr>
<tr>
<td><strong>X</strong></td>
<td>nach C, K, Q</td>
</tr>
</tbody>
</table>


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

<h3>Beispiel</h3>
Der Name "Müller-Lüdenscheidt" wird folgendermaßen kodiert:

<ol>
<li>Buchstabenweise Kodierung: 60550750206880022</li>
<li>Entfernen aller mehrfachen Codes: 6050750206802</li>
<li>Entfernen aller Codes "0": 65752682</li>
</ol>
