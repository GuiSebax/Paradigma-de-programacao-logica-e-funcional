#lang racket
(require examples)

;;; Guilherme Frare Clemente - RA:124349
;;; Paradigma de Programação Lógica e Funcional - 2023
;;; Trabalho sobre Tabela do Campeonato Brasileiro de Futebol

;;; Como eu uso PowerShell, para executar o código eu usei o comando -> cat jogos.txt | racket main.rkt

(struct jogo (time1 gols1 time2 gols2) #:transparent)
(struct desempenho (time pontos vitorias saldo-gols) #:transparent)


;;; Análise
;;; Verificar se um determinado time(representado como uma string) já existe na lista de times

;;; Definição de tipos de dados
;;; time é uma string
;;; lista-times é uma lista de times, ou seja, uma lista de strings contendo os times que jogaram

;;; Especificação
;;; Verificar se um determinado time já existe em lista-times
;;; ja-existe? : time lista-times -> booleano
;;; retorna #t se o time já existe em lista-times e #f caso contrário
(define (ja-existe? time lista-times)
  (cond
    [(empty? lista-times) #f]
    [(equal? time (first lista-times)) #t]
    [else (ja-existe? time (rest lista-times))]))
  
(examples
(check-equal? (ja-existe? empty empty) #f)
(check-equal? (ja-existe? "Sao-Paulo" empty) #f)
(check-equal? (ja-existe? "Flamengo" (list "Flamengo")) #t)
(check-equal? (ja-existe? "Palmeiras" (list "Athletico-MG")) #f)
(check-equal? (ja-existe? "Flamengo" (list "Palmeiras" "Flamengo")) #t)
(check-equal? (ja-existe? "Sao-Paulo" (list "Sao-Paulo" "Athletico-MG" "Flamengo")) #t)
(check-equal? (ja-existe? "Atheltico-MG" (list "Sao-Paulo" "Flamengo")) #f))

;;; Análise
;;; Encontrar os nomes dos times que jogaram em uma lista de jogos

;;; Definição de tipos de dados
;;; times é uma lista de jogos (struct jogo)

;;; Especificação
;;; Encontrar os nomes dos times que jogaram em time, retornando uma lista de strings dos times que jogaram
;;; encontra-times : times -> lista-times
(define (encontra-times times)
  (cond
    [(empty? times) empty]
    [else
     (define time1 (jogo-time1 (first times)))
     (define time2 (jogo-time2 (first times)))
     (define rest-times (encontra-times (rest times)))
     (if (ja-existe? time1 rest-times)
         (if (ja-existe? time2 rest-times)
             rest-times
             (cons time2 rest-times))
         (if (ja-existe? time2 rest-times)
             (cons time1 rest-times)
             (cons time1 (cons time2 rest-times))))]))

(examples
(check-equal? (encontra-times empty) empty)
(check-equal? (encontra-times (list (jogo "Flamengo" 1 "Palmeiras" 1))) (list "Flamengo" "Palmeiras"))
(check-equal? (encontra-times (list (jogo "Flamengo" 1 "Palmeiras" 1) (jogo "Sao-Paulo" 1 "Palmeiras" 1))) (list "Flamengo" "Sao-Paulo" "Palmeiras"))
(check-equal? (encontra-times (list (jogo "Flamengo" 1 "Palmeiras" 1) (jogo "Sao-Paulo" 1 "Palmeiras" 1) (jogo "Sao-Paulo" 1 "Flamengo" 1))) (list "Palmeiras" "Sao-Paulo" "Flamengo"))
)

;;; Análise
;;; Atualizar o desempenho de um time, dado os números de gols (feitos e sofridos) e o desempenho atual

;;; Definição de tipos de dados
;;; desempenho é um struct que contém o nome do time, pontos, vitórias e saldo de gols(gols feitos - gols sofridos)
;;; gols-feitos e gols-sofridos são números inteiros

;; Dados:
;; Se um time ganhar, o time ganhador recebe 3 pontos
;; Se um time empatar, ambos os times recebem 1 ponto
;; Se um time perder, o time perdedor não recebe pontos

;;; Especificação
;;; Atualizar o desempenho de um time, dado o desempenhos(desempenho atual), gols-feitos e gols-sofridos
;;; atualiza-desempenho : desempenho gols-feitos gols-sofridos -> desempenho
(define (atualiza-desempenho desempenhos gols-feitos gols-sofridos)
  (cond
    [(empty? desempenhos) empty]
    [(> gols-feitos gols-sofridos) 
     (desempenho (desempenho-time desempenhos) 
                 (+ (desempenho-pontos desempenhos) 3) 
                 (+ (desempenho-vitorias desempenhos) 1) 
                 (+ (desempenho-saldo-gols desempenhos) (- gols-feitos gols-sofridos)))]

    [(= gols-feitos gols-sofridos) 
     (desempenho (desempenho-time desempenhos) 
                 (+ (desempenho-pontos desempenhos) 1) 
                 (desempenho-vitorias desempenhos) 
                 (desempenho-saldo-gols desempenhos))]
    [else 
     (desempenho (desempenho-time desempenhos) 
                 (desempenho-pontos desempenhos) 
                 (desempenho-vitorias desempenhos) 
                 (+ (desempenho-saldo-gols desempenhos) (- gols-feitos gols-sofridos)))]))

(examples
(check-equal? (atualiza-desempenho empty 0 0) empty)
(check-equal? (atualiza-desempenho (desempenho "Flamengo" 0 0 0) 1 0) (desempenho "Flamengo" 3 1 1))
(check-equal? (atualiza-desempenho (desempenho "Palmeiras" 0 0 0) 0 0) (desempenho "Palmeiras" 1 0 0))
(check-equal? (atualiza-desempenho (desempenho "Athletico-MG" 0 0 0) 0 1) (desempenho "Athletico-MG" 0 0 -1))
(check-equal? (atualiza-desempenho (desempenho "Sao-Paulo" 3 1 1) 1 0) (desempenho "Sao-Paulo" 6 2 2)))

;;; Análise
;;; Calcular o desempenho de um time, dado o nome do time e uma lista de jogos

;;; Definição de tipos de dados
;;; time é uma string
;;; jogos é uma lista de jogos (struct jogo) contendo (time1 gols1 time2 gols2)

;; Dados:
;; Se um time ganhar, o time ganhador recebe 3 pontos
;; Se um time empatar, ambos os times recebem 1 ponto
;; Se um time perder, o time perdedor não recebe pontos

;;; Especificação
;;; Calcular o desempenho de um time, dado time(string) e jogos(struct jogo)
;;; calcula-desempenho : time jogos -> desempenho
;;; Acumulador -> Desempenho atual do time ao longo da lista de jogos
(define (calcula-desempenho time jogos)
  (foldr (lambda (jogo-atual acumulador)
           (if (equal? time (jogo-time1 jogo-atual))
               (atualiza-desempenho acumulador (jogo-gols1 jogo-atual) (jogo-gols2 jogo-atual))
               (atualiza-desempenho acumulador (jogo-gols2 jogo-atual) (jogo-gols1 jogo-atual))))
         (desempenho time 0 0 0)
         (filter (lambda (jogo)
                   (or (equal? time (jogo-time1 jogo))
                       (equal? time (jogo-time2 jogo))))
                 jogos)))

(examples
(check-equal? (calcula-desempenho "Flamengo" empty) (desempenho "Flamengo" 0 0 0))
(check-equal? (calcula-desempenho "Flamengo" (list (jogo "Flamengo" 1 "Palmeiras" 1))) (desempenho "Flamengo" 1 0 0))
(check-equal? (calcula-desempenho "Athletico-MG" (list (jogo "Athletico-MG" 1 "Palmeiras" 1) (jogo "Sao-Paulo" 1 "Palmeiras" 1) (jogo "Sao-Paulo" 1 "Athletico-MG" 1))) (desempenho "Athletico-MG" 2 0 0))
(check-equal? (calcula-desempenho "Palmeiras" (list (jogo "Flamengo" 1 "Palmeiras" 1) (jogo "Sao-Paulo" 1 "Palmeiras" 1) (jogo "Sao-Paulo" 1 "Flamengo" 1))) (desempenho "Palmeiras" 2 0 0)))

;;; Análise
;;; Calcula o desempenho de todos os times, dado uma lista de times e uma lista de jogos

;;; Definição de tipos de dados
;;; times é uma lista de strings
;;; jogos é uma lista de jogos (struct jogo) contendo (time1 gols1 time2 gols2)

;;; Especificação
;;; Calcula o desempenho de todos os times, dado times(ListaString) e jogos(struct jogo)
;;; calcula-desempenhos : times jogos -> lista-desempenhos
(define (calcula-desempenhos times jogos)
  (map (lambda (time) (calcula-desempenho time jogos)) times))

(examples
(check-equal? (calcula-desempenhos empty empty) empty)
(check-equal? (calcula-desempenhos (list "Flamengo") empty) (list (desempenho "Flamengo" 0 0 0)))
(check-equal? (calcula-desempenhos (list "Flamengo" "Palmeiras") (list (jogo "Flamengo" 1 "Palmeiras" 1))) (list (desempenho "Flamengo" 1 0 0) (desempenho "Palmeiras" 1 0 0)))
(check-equal? (calcula-desempenhos (list "Flamengo" "Palmeiras" "Sao-Paulo") (list (jogo "Flamengo" 1 "Palmeiras" 1) (jogo "Sao-Paulo" 1 "Palmeiras" 1) (jogo "Sao-Paulo" 1 "Flamengo" 1))) (list (desempenho "Flamengo" 2 0 0) (desempenho "Palmeiras" 2 0 0) (desempenho "Sao-Paulo" 2 0 0)))
(check-equal? (calcula-desempenhos (list "Flamengo" "Palmeiras" "Sao-Paulo" "Athletico-MG") (list (jogo "Flamengo" 1 "Palmeiras" 1) (jogo "Sao-Paulo" 1 "Palmeiras" 1) (jogo "Sao-Paulo" 1 "Flamengo" 1) (jogo "Athletico-MG" 1 "Palmeiras" 1) (jogo "Sao-Paulo" 1 "Athletico-MG" 1))) (list (desempenho "Flamengo" 2 0 0) (desempenho "Palmeiras" 3 0 0) (desempenho "Sao-Paulo" 3 0 0) (desempenho "Athletico-MG" 2 0 0))))


;;; Análise
;;; Compara dois desempenhos, levanando em consideração primeiramente os pontos, se caso empatar,
;;; compara as vitórias, e o mesmo para o saldo de gols, e por fim, se ainda estiver empatado, compara
;;; os nomes dos times

;;; Definição de tipos de dados
;;; d1 é uma struct desempenho 
;;; d2 é uma struct desempenho

;;; Especificação
;;; compara-desempenhos : d1 d2 -> booleano
;;; compara d1 e d2 (struct desempenho para ambos), verificando primeiramente os pontos (quem tem mais pontos ganha),
;;; se caso empatar, verifica as vitórias (quem tem mais vitórias ganha), se caso empatar, verifica o saldo de gols
;;; (quem tem mais saldo de gols ganha), e se ainda estiver empatado, verifica o nome dos times (ordem alfabética)
;;; retorna #t se as validações forem verdadeiras e #f caso contrário
(define (compara-desempenhos d1 d2)
  (cond
    [(> (desempenho-pontos d1) (desempenho-pontos d2)) #t]
    [(< (desempenho-pontos d1) (desempenho-pontos d2)) #f]
    [(> (desempenho-vitorias d1) (desempenho-vitorias d2)) #t]
    [(< (desempenho-vitorias d1) (desempenho-vitorias d2)) #f]
    [(> (desempenho-saldo-gols d1) (desempenho-saldo-gols d2)) #t]
    [(< (desempenho-saldo-gols d1) (desempenho-saldo-gols d2)) #f]
    [else (string<=? (desempenho-time d1) (desempenho-time d2))]))

(examples
(check-equal? (compara-desempenhos (desempenho "Flamengo" 0 0 0) (desempenho "Palmeiras" 0 0 0)) #t)
(check-equal? (compara-desempenhos (desempenho "Sao-Paulo" 1 0 0) (desempenho "Cuiabá" 2 0 0)) #f)
(check-equal? (compara-desempenhos (desempenho "Athletico-MG" 1 0 0) (desempenho "Sao-Paulo" 1 0 0)) #t)
(check-equal? (compara-desempenhos (desempenho "Flamengo" 1 1 0) (desempenho "Chapecoense" 1 1 1)) #f))

;;; Análise
;;; Ordena uma lista de desempenhos, dado uma lista de desempenhos e uma função de comparação(representada pela compara-desempenhos)

;;; Definição de tipos de dados
;;; lst-desempenhos é uma lista de desempenhos
;;; comp é uma função de comparação (que representa a função compara-desempenhos)

;;; Especificação
;;; Ordena uma lista de desempenhos, dado lst-desempenhos e a função compara-desempenhos como valor
;;; ordena-desempenhos : lst-desempenhos comp(desempenho desempenho -> booleano) -> lst-desempenhos
(define (ordena-desempenhos lst-desempenhos comp)
  (cond
    [(empty? lst-desempenhos) empty]
    [else (insere-desempenho-ordenado (first lst-desempenhos) (ordena-desempenhos (rest lst-desempenhos) comp) comp)]))

(examples
(check-equal? (ordena-desempenhos empty compara-desempenhos) empty)
(check-equal? (ordena-desempenhos (list (desempenho "Flamengo" 0 0 0)) compara-desempenhos) (list (desempenho "Flamengo" 0 0 0)))
(check-equal? (ordena-desempenhos (list (desempenho "Flamengo" 0 0 0) (desempenho "Palmeiras" 0 0 0)) compara-desempenhos) (list (desempenho "Flamengo" 0 0 0) (desempenho "Palmeiras" 0 0 0)))
(check-equal? (ordena-desempenhos (list (desempenho "Flamengo" 0 0 0) (desempenho "Palmeiras" 0 0 0) (desempenho "Sao-Paulo" 0 0 0)) compara-desempenhos) (list (desempenho "Flamengo" 0 0 0) (desempenho "Palmeiras" 0 0 0) (desempenho "Sao-Paulo" 0 0 0))))


;;; Análise
;;; Insere um desempenho em uma lista de desempenhos ordenada, dado um desempenho, uma lista de desempenhos e a função compara-desempenhos

;;; Definição de tipos de dados
;;; desempenho é um struct desempenho
;;; lst-desempenhos é uma lista de desempenhos
;;; comp é uma função de comparação (que representa a função compara-desempenhos)

;;; Especificação
;;; Insere um desempenho em uma lista de desempenhos ordenada, dado desempenho, lst-desempenhos e a função compara-desempenhos como valor
;;; insere-desempenho-ordenado : desempenho lst-desempenhos comp(desempenho desempenho -> booleano) -> lst-desempenhos
(define (insere-desempenho-ordenado desempenho lst-desempenhos comp)
  (cond
    [(empty? lst-desempenhos) (cons desempenho empty)]
    [(comp desempenho (first lst-desempenhos)) (cons desempenho lst-desempenhos)]
    [else (cons (first lst-desempenhos) (insere-desempenho-ordenado desempenho (rest lst-desempenhos) comp))]))

(examples
(check-equal? (insere-desempenho-ordenado (desempenho "Flamengo" 0 0 0) empty compara-desempenhos) (list (desempenho "Flamengo" 0 0 0)))
(check-equal? (insere-desempenho-ordenado (desempenho "Flamengo" 6 2 2) (list (desempenho "Palmeiras" 1 0 -1)) compara-desempenhos) (list (desempenho "Flamengo" 6 2 2) (desempenho "Palmeiras" 1 0 -1)))
(check-equal? (insere-desempenho-ordenado (desempenho "Flamengo" 6 2 2) (list (desempenho "Palmeiras" 1 0 -1) (desempenho "Sao-Paulo" 1 0 -1)) compara-desempenhos) (list (desempenho "Flamengo" 6 2 2) (desempenho "Palmeiras" 1 0 -1) (desempenho "Sao-Paulo" 1 0 -1)))
)

;;; Análise
;;; Faz a classificação dos times pelo desempenho
;;; Se dois times tiverem o mesmo desempenho, o critério de desempate é os pontos, vitórias, saldo de gols e nome do time

;;; Definição de tipos de dados
;;; desempenhos é uma lista de desempenhos da struct desempenho

;;; Especificação
;;; Faz a classificação dos times pelo desempenho, dado desempenhos
;;; classifica : desempenhos (ListaDesempenhos) -> desempenhos (ListaDesempenhos)
(define (classifica desempenhos)
  (ordena-desempenhos desempenhos compara-desempenhos))

(examples
(check-equal? (classifica empty) empty)
(check-equal? (classifica (list (desempenho "Flamengo" 0 0 0))) (list (desempenho "Flamengo" 0 0 0)))
(check-equal? (classifica (list (desempenho "Flamengo" 6 2 2) (desempenho "Palmeiras" 1 0 -1))) (list (desempenho "Flamengo" 6 2 2) (desempenho "Palmeiras" 1 0 -1)))
(check-equal? (classifica (list (desempenho "Flamengo" 6 2 2) (desempenho "Palmeiras" 1 0 -1) (desempenho "Sao-Paulo" 1 0 -1))) (list (desempenho "Flamengo" 6 2 2) (desempenho "Palmeiras" 1 0 -1) (desempenho "Sao-Paulo" 1 0 -1)))
(check-equal? (classifica (list (desempenho "Flamengo" 6 2 2) (desempenho "Palmeiras" 1 0 -1) (desempenho "Sao-Paulo" 1 0 -1) (desempenho "Athletico-MG" 3 1 0))) (list (desempenho "Flamengo" 6 2 2) (desempenho "Athletico-MG" 3 1 0) (desempenho "Palmeiras" 1 0 -1) (desempenho "Sao-Paulo" 1 0 -1))))

;;; Análise
;;; Transforma a lista de strings da entrada em uma lista de resultados(jogos)

;;; Definição de tipos de dados
;;; sresultados é uma lista de strings

;;; Especificação
;;; string->resultado : sresultado -> resultados
;;; Transforma sresultado (lista de strings) em uma lista de resultados(jogos), separando os elementos da lista de strings
;;; e convertendo em um struct jogo
(define (string->resultado sresultado)
  (jogo (first (string-split sresultado))
        (string->number (second (string-split sresultado)))
        (first (rest (rest (string-split sresultado))))
        (string->number (first (rest (rest (rest (string-split sresultado))))))))

(examples
(check-equal? (string->resultado "Flamengo 1 Palmeiras 1") (jogo "Flamengo" 1 "Palmeiras" 1))
(check-equal? (string->resultado "Sao-Paulo 1 Palmeiras 1") (jogo "Sao-Paulo" 1 "Palmeiras" 1))
(check-equal? (string->resultado "Sao-Paulo 1 Flamengo 1") (jogo "Sao-Paulo" 1 "Flamengo" 1))
(check-equal? (string->resultado "Athletico-MG 1 Palmeiras 1") (jogo "Athletico-MG" 1 "Palmeiras" 1)))

;;; Análise
;;; Transforma classificação (lista de desempenhos) em uma lista de strings

;;; Definição de tipos de dados
;;; classificacao é uma lista de desempenhos da struct desempenho

;;; Especificação
;;; classificacao->string : classificacao -> lista-strings
;;; Transforma classificacao (lista de desempenhos) em uma lista de strings, concatenando o nome do time, pontos, vitórias e saldo de gols
(define (desempenho->string desempenho)
  (string-append (desempenho-time desempenho) "    "
                 (number->string (desempenho-pontos desempenho)) "  "
                 (number->string (desempenho-vitorias desempenho)) "   "
                 (number->string (desempenho-saldo-gols desempenho))))

(examples
(check-equal? (desempenho->string (desempenho "Flamengo" 0 0 0)) "Flamengo    0  0   0")
(check-equal? (desempenho->string (desempenho "Palmeiras" 1 0 -1)) "Palmeiras    1  0   -1")
(check-equal? (desempenho->string (desempenho "Sao-Paulo" 1 0 -1)) "Sao-Paulo    1  0   -1")
(check-equal? (desempenho->string (desempenho "Athletico-MG" 3 1 0)) "Athletico-MG    3  1   0"))

;;; Análise
;;; Classifica os times pelo desempenho, dado uma lista de resultados(jogos)

;;; Definição de tipos de dados
;;; sresultados é uma lista de strings

;;; Especificação
;;; classifica-times : sresultados -> lista-strings (ListaString -> ListaString)
;;; Classifica os times pelo desempenho, dado sresultados (lista de strings), transformando em uma lista de resultados(jogos),
;;; encontrando os times que jogaram, calculando o desempenho de cada time, e por fim, classificando os times pelo desempenho
(define (classifica-times sresultados)

  (define resultados (map string->resultado sresultados))
  (define times (encontra-times resultados))
  (define desempenhos (calcula-desempenhos times resultados))
  (define classificacao (classifica desempenhos))
  (map desempenho->string classificacao))

(examples
(check-equal? (classifica-times empty) empty)
(check-equal? (classifica-times (list "Flamengo 1 Palmeiras 1")) (list "Flamengo    1  0   0" "Palmeiras    1  0   0"))
(check-equal? (classifica-times (list "Flamengo 1 Palmeiras 1" "Sao-Paulo 1 Palmeiras 1" "Sao-Paulo 1 Flamengo 1")) (list "Flamengo    2  0   0" "Palmeiras    2  0   0" "Sao-Paulo    2  0   0"))
(check-equal? (classifica-times (list "Flamengo 1 Palmeiras 1" "Sao-Paulo 1 Palmeiras 1" "Sao-Paulo 1 Flamengo 1" "Athletico-MG 1 Palmeiras 1" "Sao-Paulo 1 Athletico-MG 1")) (list "Palmeiras    3  0   0" "Sao-Paulo    3  0   0" "Athletico-MG    2  0   0" "Flamengo    2  0   0")))


;;; Observação: para executar e ver somente os exemplos de teste, comente a função abaixo
(display-lines (classifica-times (port->lines)))

  


