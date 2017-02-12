<?php

/**
 * Phonetik für die deutsche Sprache nach dem Kölner Verfahren
 *
 * Die Kölner Phonetik (auch Kölner Verfahren) ist ein phonetischer Algorithmus,
 * der Wörtern nach ihrem Sprachklang eine Zeichenfolge zuordnet, den phonetischen
 * Code. Ziel dieses Verfahrens ist es, gleich klingenden Wörtern den selben Code
 * zuzuordnen, um bei Suchfunktionen eine Ähnlichkeitssuche zu implementieren. Damit
 * ist es beispielsweise möglich, in einer Namensliste Einträge wie "Meier" auch unter
 * anderen Schreibweisen, wie "Maier", "Mayer" oder "Mayr", zu finden.
 *
 * Die Kölner Phonetik ist, im Vergleich zum bekannteren Russell-Soundex-Verfahren,
 * besser auf die deutsche Sprache abgestimmt. Sie wurde 1969 von Postel veröffentlicht.
 *
 * Infos: http://www.uni-koeln.de/phil-fak/phonetik/Lehre/MA-Arbeiten/magister_wilz.pdf
 *
 * Die Umwandlung eines Wortes erfolgt in drei Schritten:
 *
 * 1. buchstabenweise Codierung von links nach rechts entsprechend der Umwandlungstabelle
 * 2. entfernen aller mehrfachen Codes
 * 3. entfernen aller Codes "0" ausser am Anfang
 *
 * Beispiel  Der Name "Müller-Lüdenscheidt" wird folgendermaßen kodiert:
 *
 * 1. buchstabenweise Codierung: 60550750206880022
 * 2. entfernen aller mehrfachen Codes: 6050750206802
 * 3. entfernen aller Codes "0": 65752682
 *
 * Umwandlungstabelle:
 * ============================================
 * Buchstabe      Kontext                  Code
 * -------------  -----------------------  ----
 * A,E,I,J,O,U,Y                            0
 * H                                        -
 * B                                        1
 * P              nicht vor H               1
 * D,T            nicht vor C,S,Z           2
 * F,V,W                                    3
 * P              vor H                     3
 * G,K,Q                                    4
 * C              im Wortanfang
 *                vor A,H,K,L,O,Q,R,U,X     4
 * C              vor A,H,K,O,Q,U,X
 *                ausser nach S,Z           4
 * X              nicht nach C,K,Q         48
 * L                                        5
 * M,N                                      6
 * R                                        7
 * S,Z                                      8
 * C              nach S,Z                  8
 * C              im Wortanfang ausser vor
 *                A,H,K,L,O,Q,R,U,X         8
 * C              nicht vor A,H,K,O,Q,U,X   8
 * D,T            vor C,S,Z                 8
 * X              nach C,K,Q                8
 * --------------------------------------------
 *
 * ---------------------------------------------------------------------
 * Support/Info/Download: https://github.com/deezaster/germanphonetic
 * ---------------------------------------------------------------------
 *
 * @package    x3m
 * @version    1.3
 * @author     Andy Theiler <andy@x3m.ch>
 * @copyright  Copyright (c) 1996 - 2014, Xtreme Software GmbH, Switzerland (www.x3m.ch)
 * @license    http://www.opensource.org/licenses/bsd-license.php  BSD License
 */
function soundex_ger($word)
{
   //echo "<br>input: <b>" . $word . "</b>";

   $code = "";
   $word = strtolower($word);

   if (strlen($word) < 1) {
      return "";
   }

   // Umwandlung: v->f, w->f, j->i, y->i, ph->f, ä->a, ö->o, ü->u, ß->ss, é->e, è->e, ê->e, à->a, á->a, â->a, ë->e
   $word = str_replace(array("ç", "v", "w", "j", "y", "ph", "ä", "ö", "ü", "ß", "é", "è", "ê", "à", "á", "â", "ë"), array("c", "f", "f", "i", "i", "f", "a", "o", "u", "ss", "e", "e", "e", "a", "a", "a", "e"), $word);
   //echo "<br>optimiert1: <b>" . $word . "</b>";

   // Nur Buchstaben (keine Zahlen, keine Sonderzeichen)
   $word = preg_replace('/[^a-zA-Z]/', '', $word);
   //echo "<br>optimiert2: <b>" . $word . "</b>";


   $wordlen = strlen($word);
   $char = str_split($word);


   // Sonderfälle bei Wortanfang (Anlaut)
   if ($char[0] == 'c') {
      if ($wordlen == 1) {
         $code = 8;
         $x = 1;
      } else {
         // vor a,h,k,l,o,q,r,u,x
         switch ($char[1]) {
            case 'a':
            case 'h':
            case 'k':
            case 'l':
            case 'o':
            case 'q':
            case 'r':
            case 'u':
            case 'x':
               $code = "4";
               break;
            default:
               $code = "8";
               break;
         }
         $x = 1;
      }
   } else {
      $x = 0;
   }

   for (; $x < $wordlen; $x++) {

      switch ($char[$x]) {
         case 'a':
         case 'e':
         case 'i':
         case 'o':
         case 'u':
            $code .= "0";
            break;
         case 'b':
         case 'p':
            $code .= "1";
            break;
         case 'd':
         case 't':
            if ($x + 1 < $wordlen) {
               switch ($char[$x + 1]) {
                  case 'c':
                  case 's':
                  case 'z':
                     $code .= "8";
                     break;
                  default:
                     $code .= "2";
                     break;
               }
            } else {
               $code .= "2";
            }
            break;
         case 'f':
            $code .= "3";
            break;
         case 'g':
         case 'k':
         case 'q':
            $code .= "4";
            break;
         case 'c':
            if ($x + 1 < $wordlen) {
               switch ($char[$x + 1]) {
                  case 'a':
                  case 'h':
                  case 'k':
                  case 'o':
                  case 'q':
                  case 'u':
                  case 'x':
                     switch ($char[$x - 1]) {
                        case 's':
                        case 'z':
                           $code .= "8";
                           break;
                        default:
                           $code .= "4";
                     }
                     break;
                  default:
                     $code .= "8";
                     break;
               }
            } else {
               $code .= "4";
            }
            break;
         case 'x':
            if ($x > 0) {
               switch ($char[$x - 1]) {
                  case 'c':
                  case 'k':
                  case 'q':
                     $code .= "8";
                     break;
                  default:
                     $code .= "48";
                     break;
               }
            } else {
               $code .= "48";
            }
            break;
         case 'l':
            $code .= "5";
            break;
         case 'm':
         case 'n':
            $code .= "6";
            break;
         case 'r':
            $code .= "7";
            break;
         case 's':
         case 'z':
            $code .= "8";
            break;
      }

   }
   //echo "<br>code1: <b>" . $code . "</b><br />";

   // Mehrfach Codes entfernen
   $code = preg_replace("/(.)\\1+/", "\\1", $code);

   //echo "<br>code2: <b>" . $code . "</b><br />";

   // entfernen aller Codes "0" ausser am Anfang
   $codelen = strlen($code);
   $num = array();
   $num = str_split($code);
   $phoneticcode = $num[0];

   for ($x = 1; $x < $codelen; $x++) {
      if ($num[$x] != "0") {
         $phoneticcode .= $num[$x];
      }
   }

   return $phoneticcode;
}

?>