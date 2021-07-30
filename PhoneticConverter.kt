package com.rescueservices.phoneticconverter

import android.util.Log
import java.util.*

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
 * Beispiel  Der Name "Müller-Lüdenscheidt" wird folgendermaßen kodiert:
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
    companion object {
        const val TAG = "PhoneticConverter"
    }

    fun phoneticCode(input: String): ArrayList<Char?> {
        val string = input.trim { it <= ' ' }
        Log.d(TAG, "input: $string")
        val code = CharArray(string.length)
        if (string.isEmpty()) {
            return ArrayList()
        }
        var word = string.lowercase(Locale.ROOT)
        word = changeUnnecessary(word)
        Log.d(TAG, "optimised1: $word")

        // removing all special character.
        word = word.replace("[^A-Za-z0-9 ]".toRegex(), "")
        Log.d(TAG, "optimised2: $word")
        val chars = word.toCharArray()
        var i: Int

        // Specials at word beginning
        if (chars[0] == 'c') {
            if (word.length == 1) {
                code[0] = '8'
            } else {
                // before a,h,k,l,o,q,r,u,x
                when (chars[1]) {
                    'a', 'h', 'k', 'l', 'o', 'q', 'r', 'u', 'x' -> code[0] = '4'
                    else -> code[0] = '8'
                }
            }
            i = 1
        } else {
            i = 0
        }
        while (i < word.length) {
            when (chars[i]) {
                'a', 'e', 'i', 'o', 'u' -> code[i] = '0'
                'b', 'p' -> code[i] = '1'
                'd', 't' -> if (i + 1 < word.length) {
                    when (chars[i + 1]) {
                        'c', 's', 'z' -> code[i] = '8'
                        else -> code[i] = '2'
                    }
                } else {
                    code[i] = '2'
                }
                'f' -> code[i] = '3'
                'g', 'k', 'q' -> code[i] = '4'
                'c' -> if (i + 1 < word.length) {
                    when (chars[i + 1]) {
                        'a', 'h', 'k', 'o', 'q', 'u', 'x' -> when (chars[i - 1]) {
                            's', 'z' -> code[i] = '8'
                            else -> code[i] = '4'
                        }
                        else -> code[i] = '8'
                    }
                } else {
                    code[i] = '4'
                }
                'x' -> if (i > 0) {
                    when (chars[i - 1]) {
                        'c', 'k', 'q' -> code[i] = '8'
                        else -> {
                            code[i] = 48.toChar()
                        }

                    }
                } else {
                    code[i] = 48.toChar()
                }
                'l' -> code[i] = '5'
                'm', 'n' -> code[i] = '6'
                'r' -> code[i] = '7'
                's', 'z' -> code[i] = '8'
            }
            i++
        }
        Log.d(TAG, "code1: " + code.contentToString())

        // delete multiple codes
        // use regex "(.)(?=.*)(\\1)", "\\1" to find the duplicates and delete the first of its group
        // both method are possible
        val codeLength = code.size
        //val preList = CharArray(codeLength)
        val arrayList = ArrayList<Char?>()
        i = 0
        while (i < codeLength) {
            if (i + 1 < codeLength) {
                if (code[i] == code[i + 1]) {
                    if (code[i] != 0.toChar() && code[i] != '0') {
                        arrayList.add(code[i])
                    }
                    i++
                } else {
                    if (code[i] != 0.toChar() && code[i] != '0') {
                        arrayList.add(code[i])
                    }
                }
            }
            i++
        }
        Log.d(TAG, "finished: " + arrayList + arrayList.size)


        return arrayList
    }

    private fun changeUnnecessary(original: String): String {
        // Conversion: v->f, w->f, j->i, y->i, ph->f, ä->a, ö->o, ü->u, ß->ss, é->e, è->e, ê->e, à->a, á->a, â->a, ë->e
        var text = original
        val regex1 = ArrayList<String>()
        regex1.add("ç")
        regex1.add("v")
        regex1.add("w")
        regex1.add("j")
        regex1.add("y")
        regex1.add("ph")
        regex1.add("ä")
        regex1.add("ö")
        regex1.add("ü")
        regex1.add("ß")
        regex1.add("é")
        regex1.add("è")
        regex1.add("ê")
        regex1.add("à")
        regex1.add("á")
        regex1.add("â")
        regex1.add("ë")
        val regex2 = ArrayList<String>()
        regex2.add("c")
        regex2.add("f")
        regex2.add("f")
        regex2.add("i")
        regex2.add("i")
        regex2.add("f")
        regex2.add("a")
        regex2.add("o")
        regex2.add("u")
        regex2.add("ss")
        regex2.add("e")
        regex2.add("e")
        regex2.add("e")
        regex2.add("a")
        regex2.add("a")
        regex2.add("a")
        regex2.add("e")
        for (i in 0..16) {
            text = original.replace(regex1[i], regex2[i])
        }
        return text
    }
}

