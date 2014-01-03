/**
	Inhalt:
		SOUNDEX_GER():       Codierung deutscher Namen nach dem Kölner Verfahren
		SOUNDEX_GER_MW():    Multi-Word-Wrapper für SOUNDEX_GER()

**/


  /**
   * Oracle PL/SQL Function: "German Phonetic" - Phonetik für die deutsche Sprache nach dem Kölner Verfahren
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
   *
   * ---------------------------------------------------------------------
   * Support/Info/Download: https://github.com/deezaster/germanphonetic
   * ---------------------------------------------------------------------
   *
   * @package    x3m
   * @version    1.2
   * @author     Andy Theiler <andy.theiler@x3m.ch>
   * @copyright  Copyright (c) 1996 - 2010, Xtreme Software GmbH, Switzerland (www.x3m.ch)
   * @license    http://www.opensource.org/licenses/bsd-license.php  BSD License
   *
   * W.Frick, 10/2011: Bug Fix & Performance Tuning (Dauer ca. 1/3 gegenüber Original) und Multi-Word Version SOUNDEX_GER_MW()
   */
   
   CREATE OR REPLACE FUNCTION "SOUNDEX_GER" (strWord IN VARCHAR2,
                                             intLen IN NUMBER DEFAULT 255)
				return VARCHAR2  is
      
     Word varchar2(255);
     WordLen number;
     checkLen number;
     Code varchar2(255);
     PhoneticCode varchar2(255);
     intX number;
   
   begin
   
        if intLen is null then checkLen := 255; else checkLen := intLen; end if;
   
        Word := lower(substr(strWord,0,checkLen));
        if length(Word) < 1 then return 0; end if;

   
        -- Umwandlung:
        -- v->f, w->f, j->i, y->i, ph->f, ä->a, ö->o, ü->u, ß->ss, é->e, è->e, à->a, ç->c
        -- Nur Buchstaben (keine Zahlen, keine Sonderzeichen)

        Word := REGEXP_REPLACE(
			REPLACE(
				REPLACE(
					Translate(Word, 'vwjyäöüéèêàáç', 'ffiiaoueeeaac'),
				'ph', 'f'),
			'ß', 'ss'),
		'[^a-zA-Z]', Null);


        WordLen := LENGTH(Word);
	-- Wir hängen bei 1-buchstabigen Strings ein Leerzeichen an, sonst funktioniert die Anlautprüfung auf den zweiten Buchstaben nicht. 
	If WordLen = 1 Then Word := Word || ' ' ; End If;
   
        -- Sonderfälle bei Wortanfang (Anlaut)
        if substr(Word,1,1) = 'c' then
           -- vor a,h,k,l,o,q,r,u,x
           case
             when substr(Word,2,1) in ('a','h','k','l','o','q','r','u','x') then
                Code := '4';
             else
                Code := '8';
           end case;
           intX := 2;
        else
           intX := 1;
        end if;
   
        while intX <= WordLen loop
           case
             when substr(Word,intX,1) in ('a','e','i','o','u') then
                Code := Code || '0';
             when substr(Word,intX,1) = 'b' or  substr(Word,intX,1) = 'p' then
                Code := Code || '1';
             when substr(Word,intX,1) = 'd' or  substr(Word,intX,1) = 't' then
                if intX < WordLen then
                   case
                     when substr(Word,intX+1,1) in ('c','s','z') then
                        Code := Code || '8';
                     else
                        Code := Code || '2';
                   end case;
                else
                   Code := Code || '2';
                end if;
             when substr(Word,intX,1) = 'f' then
                Code := Code || '3';
             when substr(Word,intX,1) in ('g','k','q') then
                Code := Code || '4';
             when substr(Word,intX,1) = 'c' then
                if intX < WordLen then
                   case
                     when substr(Word,intX+1,1) in ('a','h','k','o','q','u','x') then
                        case
                          when substr(Word,intX-1,1) = 's' or substr(Word,intX-1,1) = 'z' then
                             Code := Code || '8';
                          else
                             Code := Code || '4';
                        end case;
                     else
                        Code := Code || '8';
                   end case;
                else
                   Code := Code || '8';
                end if;
             when substr(Word,intX,1) = 'x' then
                if intX > 1 then
                   case
                     when substr(Word,intX-1,1) in ('c','k','x') then
                        Code := Code || '8';
                     else
                        Code := Code || '48';
                   end case;
                else
                   Code := Code || '48';
                end if;
             when substr(Word,intX,1) = 'l' then
                Code := Code || '5';
             when substr(Word,intX,1) = 'm' or substr(Word,intX,1) = 'n' then
                Code := Code || '6';
             when substr(Word,intX,1) = 'r' then
                Code := Code || '7';
             when substr(Word,intX,1) = 's' or substr(Word,intX,1) = 'z' then
                Code := Code || '8';
             else
                Code := Code;
           end case;
   
           intX := intX + 1;
        end loop;
      
        -- Issue #3: zuerst die mehrfachen Codes entfernen und erst dann die "0" eliminieren
        -- PhoneticCode := regexp_replace(Translate(Code, '1234567890', '123456789'), '(.)\1+', '\1');
        PhoneticCode := Translate(regexp_replace(Code, '(.)\1+', '\1'), '1234567890', '123456789');
        
	-- Am Wortanfang bleiben "0"-Codes erhalten
        IF  Substr(Code,1,1) = '0' THEN PhoneticCode := '0' || PhoneticCode;  END IF;

        return PhoneticCode;
   
   end SOUNDEX_GER;
/



   CREATE OR REPLACE FUNCTION "SOUNDEX_GER_MW" (strWord IN VARCHAR2) return VARCHAR2 Is
   -- Die Funktion bricht den Eingabe-String in einzelne Worte auf und codiert jedes einzelne Wort mit SOUNDEX_GER()
   -- Author: W.Frick, 10/2011

   len number;
   i number;
   k number;
   in_string varchar2(4000);
   out_string varchar2(4000);
   KEY_LENGTH constant number := 4;

   Begin
	i := 1;
	out_string := null ;
	--16.10.2012 Andy Theiler: Zeilenumbruch entfernen bzw wie eine Worttrennung behandeln.
	--in_string := substr(Translate(strWord,'.,-;','    '),1,4000);
	in_string := REGEXP_REPLACE(substr(Translate(strWord,'.,-;','    '),1,4000),  '([[:cntrl:]])|(^\t)', ' ');   
	
	len := Length(in_string) ;

        while i <= len loop
		k := InStr(in_string, ' ', i);
		Case
		   When (k = i) Then i := i +1;
		   When (k > i) Then
			out_string := trim(out_string || ' ' || substr(SOUNDEX_GER(substr(in_string, i, k-i)),1,KEY_LENGTH)) ;
			i := k+1 ;
		   When (K = 0) Then
			out_string := trim(out_string || ' ' || substr(SOUNDEX_GER(substr(in_string, i)),1,KEY_LENGTH)) ;
			i := len +1;
           	End case;
        end loop;

	return out_string;
   End SOUNDEX_GER_MW;
/
