import 'package:flutter/material.dart';

/// Copyright (C) 2020 Google Inc. All Rights Reserved.
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///      http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

/// Phonetik für die deutsche Sprache nach dem Kölner Verfahren
/// <p>
/// Die Kölner Phonetik (auch Kölner Verfahren) ist ein phonetischer Algorithmus,
/// der Wörtern nach ihrem Sprachklang eine Zeichenfolge zuordnet, den phonetischen
/// Code. Ziel dieses Verfahrens ist es, gleich klingenden Wörtern den selben Code
/// zuzuordnen, um bei Suchfunktionen eine Ähnlichkeitssuche zu implementieren. Damit
/// ist es beispielsweise möglich, in einer Namensliste Einträge wie "Meier" auch unter
/// anderen Schreibweisen, wie "Maier", "Mayer" oder "Mayr", zu finden.
/// <p>
/// Die Kölner Phonetik ist, im Vergleich zum bekannteren Russell-Soundex-Verfahren,
/// besser auf die deutsche Sprache abgestimmt. Sie wurde 1969 von Postel veröffentlicht.
/// <p>
/// Infos: http://www.uni-koeln.de/phil-fak/phonetik/Lehre/MA-Arbeiten/magister_wilz.pdf
/// <p>
/// Die Umwandlung eines Wortes erfolgt in drei Schritten:
/// <p>
/// 1. buchstabenweise Codierung von links nach rechts entsprechend der Umwandlungstabelle
/// 2. entfernen aller mehrfachen Codes
/// 3. entfernen aller Codes "0" ausser am Anfang
/// <p>
/// Beispiel  Der Name "Müller-Lüdenscheidt" wird folgendermaßen kodiert:
/// <p>
/// 1. buchstabenweise Codierung: 60550750206880022
/// 2. entfernen aller mehrfachen Codes: 6050750206802
/// 3. entfernen aller Codes "0": 65752682
/// <p>
/// Umwandlungstabelle:
/// ============================================
/// Buchstabe      Kontext                  Code
/// -------------  -----------------------  ----
/// Rule01   A,E,I,J,O,U,Y                            0
/// Rule02   H                                        -
/// Rule03   B                                        1
/// Rule04   P              nicht vor H               1
/// Rule05   D,T            nicht vor C,S,Z           2
/// Rule06   F,V,W                                    3
/// Rule07   P              vor H                     3
/// Rule08   G,K,Q                                    4
/// Rule09   C              im Wortanfang
/// vor A,H,K,L,O,Q,R,U,X     4
/// Rule10   C              vor A,H,K,O,Q,U,X
/// ausser nach S,Z           4
/// Rule11   X              nicht nach C,K,Q         48
/// Rule12   L                                        5
/// Rule13   M,N                                      6
/// Rule14   R                                        7
/// Rule15   S,Z                                      8
/// Rule16   C              nach S,Z                  8
/// Rule17   C              im Wortanfang ausser vor
/// A,H,K,L,O,Q,R,U,X         8
/// Rule18   C              nicht vor A,H,K,O,Q,U,X   8
/// Rule19   D,T            vor C,S,Z                 8
/// Rule20   X              nach C,K,Q                8
/// --------------------------------------------
///*
/// ---------------------------------------------------------------------
/// Support/Info/Download: https://github.com/deezaster/germanphonetic
/// ---------------------------------------------------------------------
///
/// @package    germanphonetic
/// @version    1.0
/// @author     Steffen Halstrick <steffenhalstrick@t-online.de>
/// @copyright  /
/// @license    /

const String TAG = "PhoneticConverter";

List<Characters> phoneticCode(String input) {
  var string = input.trim();
  print("$TAG input: $input");
  var code = List<Characters>.empty();
  if (string.isEmpty) {
    return List<Characters>.empty();
  }
  var word = string.toLowerCase();
  word = changeUnnecessary(word);
  print("$TAG first optimization: $word");

  // removing all special character
  word.replaceAll(RegExp("[^A-Za-z0-9 ]"), "");
  print("$TAG second optimization: $word");

  // don't need to convert String to CharArray
  var i;

  // Specials at word beginning
  if (word[0] == 'c') {
    if (word.length == 1) {
      code[0] = 8 as Characters;
    } else {
      // before a,h,k,l,o,q,r,u,x
      switch (word[1]) {
        case 'a':
        case 'h':
        case 'k':
        case 'l':
        case 'o':
        case 'q':
        case 'r':
        case 'u':
        case 'x':
          code[0] = 4 as Characters;
          break;
        default:
          code[0] = 8 as Characters;
      }
    }
    i = 1;
  } else {
    i = 0;
  }

  while (i < word.length) {
    switch (word[i]) {
      case 'a':
      case 'e':
      case 'i':
      case 'o':
      case 'u':
        code[i] = 0 as Characters;
        break;

      case 'b':
      case 'p':
        code[i] = 1 as Characters;
        break;

      case 'd':
        if (i + 1 < word.length) {
          switch (word[i + 1]) {
            case 'c':
            case 's':
            case 'z':
              code[i] = 8 as Characters;
              break;
            default:
              code[i] = 2 as Characters;
              break;
          }
        } else {
          code[i] = 2 as Characters;
        }
        break;
      case 't':
        if (i + 1 < word.length) {
          switch (word[i + 1]) {
            case 'c':
            case 's':
            case 'z':
              code[i] = 8 as Characters;
              break;
            default:
              code[i] = 2 as Characters;
              break;
          }
        } else {
          code[i] = 2 as Characters;
        }
        break;

      case 'f':
        code[i] = 3 as Characters;
        break;

      case 'g':
      case 'k':
      case 'q':
        code[i] = 4 as Characters;
        break;

      case 'c':
        if (i + 1 < word.length) {
          switch (word[i + 1]) {
            case 'a':
            case 'h':
            case 'k':
            case 'o':
            case 'q':
            case 'u':
            case 'x':
              switch (word[i - 1]) {
                case 's':
                case 'z':
                  code[i] = 8 as Characters;
                  break;
                default:
                  code[i] = 4 as Characters;
                  break;
              }
              break;
            default:
              code[i] = 8 as Characters;
              break;
          }
        } else {
          code[i] = 4 as Characters;
        }
        break;
      case 'x':
        if (i > 0) {
          switch (word[i - 1]) {
            case 'c':
            case 'k':
            case 'q':
              code[i] = 8 as Characters;
              break;
            default:
              code[i] = 48 as Characters;
              break;
          }
        } else {
          code[i] = 48 as Characters;
        }
        break;
      case 'l':
        code[i] = 5 as Characters;
        break;
      case 'm':
      case 'n':
        code[i] = 6 as Characters;
        break;
      case 'r':
        code[i] = 7 as Characters;
        break;
      case 's':
      case 'z':
        code[i] = 8 as Characters;
        break;
    }
    i++;
  }
  print("$TAG unoptimized code = ${code.join()}");

  // delete multiple codes
  // use regex "(.)(?=.*)(\\1)", "\\1" to find the duplicates and delete the first of its group
  // both method are possible

  var codeLength = code.join().length;
  var list = List<Characters>.empty();
  i = 0;
  while (i < codeLength) {
    if (i + 1 < codeLength) {
      if (code[i] == code[i + 1]) {
        if (code[i] != 0 as Characters && code[i] != 0) {
          list.add(code[i]);
        }
        i++;
      } else {
        if (code[i] != 0 as Characters && code[i] != '0') {
          list.add(code[i]);
        }
      }
    }
    i++;
  }
  print("$TAG code finished = ${list.join()}");

  return list;
}

String changeUnnecessary(String original) {
  // Conversion: v->f, w->f, j->i, y->i, ph->f, ä->a, ö->o, ü->u, ß->ss, é->e, è->e, ê->e, à->a, á->a, â->a, ë->e
  var text = original;
  var regexOne = <String>[];
  regexOne.add("ç");
  regexOne.add("v");
  regexOne.add("w");
  regexOne.add("j");
  regexOne.add("y");
  regexOne.add("ph");
  regexOne.add("ä");
  regexOne.add("ö");
  regexOne.add("ü");
  regexOne.add("ß");
  regexOne.add("é");
  regexOne.add("è");
  regexOne.add("ê");
  regexOne.add("à");
  regexOne.add("á");
  regexOne.add("â");
  regexOne.add("ë");
  var regexTwo = <String>[];
  regexTwo.add("c");
  regexTwo.add("f");
  regexTwo.add("f");
  regexTwo.add("i");
  regexTwo.add("i");
  regexTwo.add("f");
  regexTwo.add("a");
  regexTwo.add("o");
  regexTwo.add("u");
  regexTwo.add("ss");
  regexTwo.add("e");
  regexTwo.add("e");
  regexTwo.add("e");
  regexTwo.add("a");
  regexTwo.add("a");
  regexTwo.add("a");
  regexTwo.add("e");

  for (var i = 0; i <= 16; i++) {
    text = original.replaceAll(regexOne[i], regexTwo[i]);
  }
  return text;
}
