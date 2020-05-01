

stosik segment stack
	dw 1024 dup(?) ; podwójne słowo, dup-duplikat ?-brak określonej wartości, pojemność 1024
	szczyt label word
stosik ends

dane segment

	wygrana_dol db 10, 13, 9, 9, 9, 9, " Wygral gracz z dolu ", 0Dh, 0Ah
				db	10, 13, 9, 9, 9, 9, " Wynik:  $"
	wygrana_gora db 10, 13, 9, 9, 9, 9, " Wygral gracz z gory ", 0Dh, 0Ah
				db 10, 13, 9, 9, 9, 9, " Wynik:  $"
	wyjscie_napis db 10, 13, 9, 9, 9, 9, " Wylaczono gre...$"
	rakieta_dol   dw 185    ;x współrzędna rakietki
	rakieta_gora  dw 185    ;x współrzędna rakietki
	d_x  dw 1  ; kierunek lotu piłki( 1- prawo, -1 - lewo)
	d_y  dw 1   ;kierunek lotu piłki( 1- dol, -1 - gora)
	ball_x   dw 140    ;x współrzędna piłeczki
	ball_y   dw 170   ;y współrzędna piłeczki
	kolor db 31   ;kolor rakietki 31
	wynik_g dw 0
	wynik_d dw 0

dane ends

ekran segment AT 0B800h 
	ek db ?
	atr db ?
ekran ends

code_seg segment

assume cs:code_seg, ds:dane, ss:stosik,es:ekran
start:

	mov  ax, seg szczyt    ;inicjujemy stosik
	mov  ss,ax
	mov  sp, offset szczyt
	mov ax,seg ekran ;pamięć ekranu do ES
	
	mov	es,ax
	mov  ax, seg dane    ;inicjujemy data segment
	mov  ds,ax
	
	call  graphics_mode   ;włączamy tryb graficzny
	call  piłka_rys    ;odrysowujemy piłkę
	call  rakieta_dol_rys    ;odrysowujemy rakietkę
	call  rakieta_gora_rys
	
	main:
 call  timer    ;śpimy jakiś czas
 call  zdarzenia   ;obsługujemy zdarzenia
 
 event:
 call  ruch_pilki   ;liczymy nowe współrzędne piłki
 call  czyszczeie    ;wyczyszczamy pole
 call  rakieta_dol_rys   ;odrysowujemy rakietkę
 call  rakieta_gora_rys
 call  piłka_rys   ;odrysowujemy piłkę
 jmp  main
	
	timer:    ;śpimy zadaną liczbę mikrosekund
 mov  cx, 0  
 mov  dx, 9000   
 mov  ah, 86h
 int  15h
	
	czyszczeie:    ;wyczyszczamy pole(zarysowujemy czarnym)
 xor  cx, cx  ;idziemy od lewego górnego piksela
 mov  dx, 63999    ;do prawego dolnego
 xor  bx, bx  ;wybieramy czarny kolor
 mov  ah, 06h 
 mov  al, 00
 int  10h

 ret
 
	graphics_mode:   ;przechodzimy w tryb graficzny 320x200
 mov  ax, 13h
 int  10h
 mov  ax, 0a000h
 mov  es, ax
 ret
	
	text_mode:    ;wracamy do trybu tekstowego
MOV	AH,0
		MOV	AL,3 
		INT	10H		
		
		
 ret
	
	zdarzenia:   ;sprawdzamy i obsługujemy zdarzenia
 xor  ax, ax
 mov  ah, 01h    ;sprawdamy czy jest coś na wejściu
 int  16h
 jz   event  ;jeżeli nic - sprawdzamy dalej
 mov  ah, 00h    
 int  16h
 cmp  ah, 75d    ;porównujemy czy to strzałka w lewo
 je   wlewo_rakieta_d
 cmp  ah, 77d    ;porównujemy czy to strzałka w prawo
 je   wprawo_rakieta_d
  cmp  ah, 2d    ;porównujemy czy to strzałka w lewo
 je   wlewo_rakieta_g
 cmp  ah, 3d    ;porównujemy czy to strzałka w prawo
 je   wprawo_rakieta_g
 cmp  ah, 1d    ;sprawdamy czy to ESC
 je   exit_pass
 jmp  event
	
	wlewo_rakieta_d:   ;obsługa ruchu w lewo
 mov  ax, rakieta_dol
 sub  ax, 15  ;przesunięcie rakietki
 cmp  ax, 50  ;sprawdzamy czy daleko od lewej ściany
 jg   lewa_sciana    ;jeżeli blizko - przesuwamy do końca
 mov  rakieta_dol, 50
 jmp  event
 
 lewa_sciana:
 mov  rakieta_dol,ax
 jmp  event
	
	wprawo_rakieta_d:   ;obsługa ruchu w prawo
 mov  ax, rakieta_dol
 add  ax, 15  ;przesunięcie rakietki
 cmp  ax, 320    ;sprawdzamy czy daleko od prawej ściany
 jl   prawa_sciana    ;jeżeli blizko - przesuwamy do końca
 mov  rakieta_dol, 320
 jmp  event
 
 prawa_sciana:
 mov  rakieta_dol, ax
 jmp  event
	
	
	
	wlewo_rakieta_g:   ;obsługa ruchu w lewo
 mov  ax, rakieta_gora
 sub  ax, 15  ;przesunięcie rakietki
 cmp  ax, 50  ;sprawdzamy czy daleko od lewej ściany
 jg   lewa_sciana2    ;jeżeli blizko - przesuwamy do końca
 mov  rakieta_gora, 50
 jmp  event
 
 lewa_sciana2:
 mov  rakieta_gora,ax
 jmp  event
	
	wprawo_rakieta_g:   ;obsługa ruchu w prawo
 mov  ax, rakieta_gora
 add  ax, 15  ;przesunięcie rakietki
 cmp  ax, 320    ;sprawdzamy czy daleko od prawej ściany
 jl   prawa_sciana2    ;jeżeli blizko - przesuwamy do końca
 mov  rakieta_gora, 320
 jmp  event
 
 prawa_sciana2:
 mov  rakieta_gora, ax
 jmp  event
	
	exit_pass:
	jmp  exit_gate ; Skok do funkcji wyswietlającej komunikat o zamknieciu gry
	
	
	wygrana1:
	inc wynik_g 
	cmp wynik_g,3
	je pom1 
				jmp pom11
			pom1:
			jmp wygrana_wypisz1 
			pom11:
	mov d_x,1
	mov d_y ,1
	mov ball_x,100 
	mov ball_y,100 
	mov rakieta_dol,185
	mov rakieta_gora,185 
	call main
	
	wygrana2:
	inc wynik_d
	cmp wynik_d,3
	je pom2 
				jmp pom21
			pom2:
			jmp wygrana_wypisz2 
			pom21:
	mov d_x,1   ;
	mov d_y ,1
	mov ball_x,100 
	mov ball_y,100
	mov rakieta_dol,185
	mov rakieta_gora,185 
	call main
	
	ruch_pilki:    ;przesuwamy piłkę i sprawdzamy na kolizje
 
 mov  ax, ball_x  ;zmieniamy x współrzędną
 add  ax, d_x
 mov  ball_x, ax
 
 mov  bx, ball_y  ;zmieniamy y współrzędną
 add  bx, d_y
 mov  ball_y, bx
 
 cmp  ax, 0  ;sprawdzamy kolizję z lewą ścianą
 jg   prawa_kol
 mov  d_x, 1   ;jeżeli wystąpiła - zmieniamy wektor co do x
 jmp  gora_kol
 
 prawa_kol:
 cmp  ax, 315    ;sprawdzamy kolizję z prawą ścianą
 jl   gora_kol
 mov  d_x, -1  ;jeżeli tak - zmieniamy wektor co do y
 
 gora_kol:
 mov  cx, rakieta_gora  ;zachowujemy pozycję rakietki
 cmp  bx, 0    ;sprawdzamy kolizję z górną ścianą
 jl wygrana2
 cmp  bx, 7 
 jg dol_kol
 add  cx, 5
 cmp  ax, cx    ;piłka nad prawą częścią rakietki
 jg dol_kol
 sub  cx, 60
 cmp  ax, cx    ;piłka nad lewą częścią rakietki
 jl   dol_kol
 cmp  bx, 7    ;kolizja z rakietką
 je   srodek2
 add  cx, 25	
 cmp  ax, cx    ;kontakt ze ścianą rakietki(obsługujemy jednakowo)
 jl   lewa_strona
 mov  d_x, 1  ;zmieniamy kierunek
 ret
 
 dol_kol:
 mov  cx, rakieta_dol  ;zachowujemy pozycję rakietki
 cmp  bx, 195    ;sprawdzamy kolizję z dolną ścianą
 jg pom3 
				jmp pom31
			pom3:
			jmp wygrana1 
			pom31:
 cmp  bx, 188    ;inaczej trafiliśmy
 jl   hit
 add  cx, 5
 cmp  ax, cx    ;piłka nad prawą częścią rakietki
 jg   hit
 sub  cx, 60
 cmp  ax, cx    ;piłka nad lewą częścią rakietki
 jl   hit
 cmp  bx, 188    ;kolizja z rakietką
 je   srodek
 add  cx, 25	
 cmp  ax, cx    ;kontakt ze ścianą rakietki(obsługujemy jednakowo)
 jl   lewa_strona
 mov  d_x, 1  ;zmieniamy kierunek
 ret
 
 lewa_strona:
 mov  d_x, -1  ;kierunek w lewo
 ret
 

   srodek2:  ;trafiliśmy rakietką
 mov  d_y, 1  ;kierunek w górę

 ret
 
  srodek:  ;trafiliśmy rakietką
 mov  d_y, -1  ;kierunek w górę


 ret
 
 
 hit:
 ret
	
	rakieta_dol_rys:   ;rysujemy rakietkę na dole
 mov  ax,61760
 mov  di, ax
 mov  al, kolor
 add  di, rakieta_dol  
 mov  cx, 4

 linia1:
 add  di, 270
 push  cx
 mov  cx, 50
 call  tworzenie_lini
 pop  cx
 loop  linia1
 ret
	
rakieta_gora_rys:   ;rysujemy rakietkę na gorze
 mov  ax,3
 mov  cx,320
 mul  cx
 mov  di, ax
 mov  al, kolor
 add  di, rakieta_gora  
 mov  cx, 4

 linia2:
 add  di, 270
 push  cx
 mov  cx, 50
 call  tworzenie_lini
 pop  cx
 loop  linia2
 ret	
	
	piłka_rys:    ;rysujemy piłkę
 mov  ax, ball_y
 mov  cx, 320
 mul  cx
 mov  di, ax
 sub  di, 315
 mov  al, 36 ;kolor piłki
 add  di, ball_x 
 mov  cx, 5
 
 linia3:
 add  di, 315
 push  cx
 mov  cx, 5
 call  tworzenie_lini
 pop  cx
 loop  linia3
 ret
	
	tworzenie_lini: 
 mov  ek[di], al
 inc  di
 loop  tworzenie_lini
 ret
	
	exit_gate:    ; komunikat o wyściu z gry
 call  text_mode

 mov  dx, offset wyjscie_napis
 mov  ah, 09
 int  21h

		mov ah, 4ch
		xor al, al
		int 21h
	
	wygrana_wypisz1:    ; komunikat o wygraniu gry
 call  text_mode
 
 mov  dx, offset wygrana_gora
 mov  ah, 09
 int  21h
  jmp print_score
  
 wygrana_wypisz2:    ; komunikat o wygraniu gry
 call  text_mode
 mov  dx, offset wygrana_dol
 mov  ah, 09
 int  21h
 jmp print_score
	
	
	print_score: 	;drukujemy liczbę nabranych punktów

		mov 			bx, wynik_g
		k1:
			mov 		ax, bx
	        mov 		bx, 0
	        mov 		dx, 000ah
	        mov 		cx, 0000 ;liczba umieszczeń na stos
		k2:
			div			dl     
	        mov 		bl, ah
	        push 		bx
	        mov 		ah, 0
	        inc 		cx	;zwiększamy licznik na 1
	        cmp 		ax, 0
	        jne 		k2   ;otrzymujemy następną cyfrę
	        mov 		ah, 02
		k3:
			pop 		dx
	        add 		dl, 30h
	        int 		21h
	        loop 		k3
			
			
		mov 			bx, wynik_d
		k4:
			mov 		ax, bx
	        mov 		bx, 0
	        mov 		dx, 000ah
	        mov 		cx, 0000 ;liczba umieszczeń na stos
		k5:
			div			dl     
	        mov 		bl, ah
	        push 		bx
	        mov 		ah, 0
	        inc 		cx	;zwiększamy licznik na 1
	        cmp 		ax, 0
	        jne 		k5   ;otrzymujemy następną cyfrę
	        mov 		ah, 02
		k6:
			pop 		dx
	        add 		dl, 30h
	        int 		21h
	        loop 		k6
		exit_cmd: ;kończymy program

		mov 		ah, 4ch
		xor 		al, al
		int 		21h

code_seg  ends
end   start