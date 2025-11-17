package workbook.challenges;
import java.util.ArrayList;
import java.util.Locale;

/**
 * Copyright (C) 2020 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


/**
 * Phonetik für die deutsche Sprache nach dem Kölner Verfahren
 * <p>
 * Die Kölner Phonetik (auch Kölner Verfahren) ist ein phonetischer Algorithmus,
 * der Wörtern nach ihrem Sprachklang eine Zeichenfolge zuordnet, den phonetischen
 * Code. Ziel dieses Verfahrens ist es, gleich klingenden Wörtern den selben Code
 * zuzuordnen, um bei Suchfunktionen eine Ähnlichkeitssuche zu implementieren. Damit
 * ist es beispielsweise möglich, in einer Namensliste Einträge wie "Meier" auch unter
 * anderen Schreibweisen, wie "Maier", "Mayer" oder "Mayr", zu finden.
 * <p>
 * Die Kölner Phonetik ist, im Vergleich zum bekannteren Russell-Soundex-Verfahren,
 * besser auf die deutsche Sprache abgestimmt. Sie wurde 1969 von Postel veröffentlicht.
 * <p>
 * Infos: http://www.uni-koeln.de/phil-fak/phonetik/Lehre/MA-Arbeiten/magister_wilz.pdf
 * <p>
 * Die Umwandlung eines Wortes erfolgt in drei Schritten:
 * <p>
 * 1. buchstabenweise Codierung von links nach rechts entsprechend der Umwandlungstabelle
 * 2. entfernen aller mehrfachen Codes
 * 3. entfernen aller Codes "0" ausser am Anfang
 * <p>
 * Beispiel: Der Name "Müller-Lüdenscheidt" wird folgendermaßen kodiert:
 * <p>
 * 1. buchstabenweise Codierung: 60550750206880022
 * 2. entfernen aller mehrfachen Codes: 6050750206802
 * 3. entfernen aller Codes "0": 65752682
 * <p>
 * Umwandlungstabelle:
 * ============================================
 * Buchstabe      Kontext                  Code
 * -------------  -----------------------  ----
 * Rule01   A,E,I,J,O,U,Y                            0
 * Rule02   H                                        -
 * Rule03   B                                        1
 * Rule04   P              nicht vor H               1
 * Rule05   D,T            nicht vor C,S,Z           2
 * Rule06   F,V,W                                    3
 * Rule07   P              vor H                     3
 * Rule08   G,K,Q                                    4
 * Rule09   C              im Wortanfang
 * vor A,H,K,L,O,Q,R,U,X     4
 * Rule10   C              vor A,H,K,O,Q,U,X
 * ausser nach S,Z           4
 * Rule11   X              nicht nach C,K,Q         48
 * Rule12   L                                        5
 * Rule13   M,N                                      6
 * Rule14   R                                        7
 * Rule15   S,Z                                      8
 * Rule16   C              nach S,Z                  8
 * Rule17   C              im Wortanfang ausser vor
 * A,H,K,L,O,Q,R,U,X         8
 * Rule18   C              nicht vor A,H,K,O,Q,U,X   8
 * Rule19   D,T            vor C,S,Z                 8
 * Rule20   X              nach C,K,Q                8
 * --------------------------------------------
 **/

class PhoneticConverter {
    private static final String TAG = "PhoneticConverter";

    public ArrayList<Character> phoneticCode(String input) {
        String string = input.trim();
        System.out.println(TAG + "input: " + string);
        char[] code = new char[string.length()];
        if (string.isEmpty()) {
            return new ArrayList<>();
        }
        String word = string.toLowerCase(Locale.ROOT);
        word = changeUnnecessary(word);
        System.out.println(TAG + "optimised1: " + word);

        // removing all special character.
        word = word.replaceAll("[^A-Za-z0-9 ]", "");
        System.out.println(TAG + "optimised2: " + word);
        char[] chars = word.toCharArray();
        int i;

        // Specials at word beginning
        if (chars[0] == 'c') {
            if (word.length() == 1) {
                code[0] = '8';
            } else {
                // before a,h,k,l,o,q,r,u,x
                switch (chars[1]) {
                    case 'a':
                    case 'h':
                    case 'k':
                    case 'l':
                    case 'o':
                    case 'q':
                    case 'r':
                    case 'u':
                    case 'x':
                        code[0] = '4';
                        break;
                    default:
                        code[0] = '8';
                        break;
                }
            }
            i = 1;
        } else {
            i = 0;
        }
        while (i < word.length()) {
            switch (chars[i]) {
                case 'a':
                case 'e':
                case 'i':
                case 'o':
                case 'u':
                    code[i] = '0';
                    break;
                case 'b':
                case 'p':
                    code[i] = '1';
                    break;
                case 'd':
                case 't':
                    if (i + 1 < word.length()) {
                        switch (chars[i + 1]) {
                            case 'c':
                            case 's':
                            case 'z':
                                code[i] = '8';
                                break;
                            default:
                                code[i] = '2';
                                break;
                        }
                    } else {
                        code[i] = '2';
                    }
                    break;
                case 'f':
                    code[i] = '3';
                    break;
                case 'g':
                case 'k':
                case 'q':
                    code[i] = '4';
                    break;
                case 'c':
                    if (i + 1 < word.length()) {
                        switch (chars[i + 1]) {
                            case 'a':
                            case 'h':
                            case 'k':
                            case 'o':
                            case 'q':
                            case 'u':
                            case 'x':
                                switch (chars[i - 1]) {
                                    case 's':
                                    case 'z':
                                        code[i] = '8';
                                        break;
                                    default:
                                        code[i] = '4';
                                        break;
                                }
                                break;
                            default:
                                code[i] = '8';
                                break;
                        }
                    } else {
                        code[i] = '4';
                    }
                    break;
                case 'x':
                    if (i > 0) {
                        switch (chars[i - 1]) {
                            case 'c':
                            case 'k':
                            case 'q':
                                code[i] = '8';
                                break;
                            default:
                                code[i] = 48; //ASCII value of '0'
                                break;
                        }
                    } else {
                        code[i] = 48; //ASCII value of '0'
                    }
                    break;
                case 'l':
                    code[i] = '5';
                    break;
                case 'm':
                case 'n':
                    code[i] = '6';
                    break;
                case 'r':
                    code[i] = '7';
                    break;
                case 's':
                case 'z':
                    code[i] = '8';
                    break;
            }
            i++;
        }
        System.out.println(TAG + "code1: " + new String(code));

        // delete multiple codes
        int codeLength = code.length;
        ArrayList<Character> arrayList = new ArrayList<>();
        i = 0;
        while (i < codeLength) {
            if (i + 1 < codeLength) {
                if (code[i] == code[i + 1]) {
                    if (code[i] != 0 && code[i] != '0') {
                        arrayList.add(code[i]);
                    }
                    i++;
                } else {
                    if (code[i] != 0 && code[i] != '0') {
                        arrayList.add(code[i]);
                    }
                }
            }
            i++;
        }
        System.out.println(TAG + "finished: " + arrayList + arrayList.size());

        return arrayList;
    }

    private String changeUnnecessary(String original) {
        // Conversion: v->f, w->f, j->i, y->i, ph->f, ä->a, ö->o, ü->u, ß->ss, é->e, è->e, ê->e, à->a, á->a, â->a, ë->e
        String text = original;
        String[] regex1 = {"ç", "v", "w", "j", "y", "ph", "ä", "ö", "ü", "ß", "é", "è", "ê", "à", "á", "â", "ë"};
        String[] regex2 = {"c", "f", "f", "i", "i", "f", "a", "o", "u", "ss", "e", "e", "e", "a", "a", "a", "e"};
        for (int i = 0; i < regex1.length; i++) {
            text = text.replace(regex1[i], regex2[i]); //Use replace instead of replaceAll for single char replacements
        }
        return text;
    }
}