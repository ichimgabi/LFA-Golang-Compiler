Ichim Dan Gabriel 331CC

***Am presupus ca toate variabilele sunt declarate printr-o singura 
litera, asa ca verificarile de variabila se fac doar prin {LETTER}

Variabile suplimentare folosite:
	Variables - Contorizez numele si tipul fiecarei variabile declarate
	Function_name - Contorizez numele fiecarei functii declarate

<COMMENT>
	Preluat din pagina de manual a flex-ului, scapa de toate comentariile de 
tipul /*...*/

<COMMENT2>
	Scapa de comentariile pe linie (cu //)

<FUNCTION>
	Retin tipul pe care il returneaza functia in return_type
	Restin numele functiei
	"(" - Dupa ce am aflat numele functiei, verific daca am mai declarat 
o alta functie cu acelasi nume (altfel, eroare).
		- Incep FUNC_VAR
	"{" - Incep sa verific interiorul functiei in FUNC_BODY

<FUNC_VAR>
	")" - Cat timp nu am ajuns la paranteza care inchide antetul functiei
iau fiecare variabila si o adaug in "Variables". In cazul in care 
variabila are deja tip, il adaug si pe el, altfel astept pana cand 
ajung la ultima variabila (care va avea cu siguranta tip) si le atribui 
acel tip tuturor celorlalte variabile

<FUNC_BODY>
	"}" - Revin in <INITIAL>
	"var " - Intru in <VARIABLES> pentru a ma ocupe de declararea variabilelor
	"return "{LETTER} - Verific daca functia poate returna ceva, comparand 
verificand daca return_type e NULL
					  - Altfel,verific daca tipul variabile returnate este acelasi 
cu tipul pe care functia il returneaza (altfel, eroare) 
	Urmatoarele regului se ocupa de cazurile particulare in care am declaratii 
fara "var" in fata

<VARIABLES>
	Pentru fiecare tip de declarare a variabilelor, verific daca au mai fost 
declarate, le adaug in lista de variabile si verific potentialele erori
	***Sunt cateva cazuri pe care nu le-am tratat (Am scris totusi regex-ul
	pentru ele in fisierul .l)

<VAR_TYPE>
	Verifica ce tip i-a fost atribuit unei variabile, in cazul in care nu a 
fost explicit (ex: var a = 5)

<VAR_TYPE_ERROR>
	Folosita daca am decalrat de mai multe ori aceeasi variabila, pentru a nu 
mai incerca sa modific tipul variabilei deja existenta (practic, doar citeste 
valorile atribuit si le ignora)

<VAR_TYPE_MULTIPLE>
	La fel ca <VAR_TYPE_ERROR>, dar pentru situatii in care am mai multe varibile 
atribuite

<TYPE_ERROR>
	Verifica daca valoarea atribuita unei variabile este de acelasi tip cu 
cel deja declarat al variabilei (altfel, eroare)

<TYPE_ERROR_MULTIPLE>
	La fel ca <TYPE_ERROR>, dar pentru situatii in care am mai multe varibile 
atribuite

main() - Descide fisierul de analizat si incepe verificarea
Utilizare: ./a.out Tests/<nume_fisier>.go
