% vim: set ft=prolog:

:- use_module(library(plunit)).
:- use_module(library(clpfd)).

% Guilherme Frare Clemente
% RA: 124349

% Um jogo é representado por uma estrutura jogo com 3 argumentos. O primeiro é
% o número de linhas (L), o segundo o número de colunas (C) e o terceiro uma
% lista (Blocos - de tamanho linhas x colunas) com os blocos do jogo. Nessa
% representação os primeiros L elementos da lista Blocos correspondem aos
% blocos da primeira linha do jogo, os próximos L blocos correspondem aos
% blocos da segunda linha do jogo e assim por diante.
%
% Dessa forma, em jogo com 3 linhas e 5 colunas (total de 15 blocos), os
% blocos são indexados da seguinte forma:
%
%  0  1  2  3  4
%  5  6  7  8  9
% 10 11 12 13 14
%
% Cada bloco é representado por uma estrutura bloco com 4 argumentos. Os
% argumentos representam os valores da borda superior, direita, inferior e
% esquerda (sentido horário começando do topo). Por exemplo o bloco
%
% |  3  |
% |4   6|  é representado por bloco(3, 6, 7, 4).
% |  7  |
%
% Dizemos que um bloco está em posição adequada se os valores das bordas
% do bloco coincidirem corretamente com os blocos adjacentes na matriz do jogo.
% As bordas de um bloco são representadas pelos quatro argumentos da estrutura 
% bloco/4, que representam, respectivamente, os valores da borda superior, direita,
% inferior e esquerda
% 
% 1- Canto Superior Esquerdo (P = 0)
%   A borda superior do bloco deve coincidir com a borda inferior do bloco abaixo.
%   A borda esquerda do bloco deve coincidir com a borda direita do bloco à direita.
% 
% 2- Canto Superior Direito (P = C - 1)
%   A borda superior do bloco deve coincidir com a borda inferior do bloco abaixo.
%   A borda direita do bloco deve coincidir com a borda esquerda do bloco à esquerda.
% 
% 3- Canto Inferior Direito (P = L * C - 1)
%   A borda inferior do bloco deve coincidir com a borda superior do bloco acima.
%   A borda direita do bloco deve coincidir com a borda esquerda do bloco à esquerda.
% 
% 4- Canto Inferior Esquerdo (P = L * C - L)
%   A borda inferior do bloco deve coincidir com a borda superior do bloco acima.
%   A borda esquerda do bloco deve coincidir com a borda direita do bloco à direita.
% 
% 5- Bordas na Primeira Linha (0 < P < C - 1)
%   A borda inferior do bloco deve coincidir com a borda superior do bloco acima.
%   A borda esquerda do bloco deve coincidir com a borda direita do bloco à direita.
%   A borda direita do bloco deve coincidir com a borda esquerda do bloco à esquerda.
% 
% 6- Bordas na Última Linha((L-1) * C < P < L * C - 1)
%   A borda inferior do bloco deve coincidir com a borda superior do bloco acima.
%   A borda esquerda do bloco deve coincidir com a borda direita do bloco à direita.
%   A borda direita do bloco deve coincidir com a borda esquerda do bloco à esquerda.
% 
% 7- Bordas na Primeira Coluna (P mod C = 0, 0 < P < (L-1) * C)
%   A borda esquerda do bloco deve coincidir com a borda direita do bloco à direita.
%   A borda superior do bloco deve coincidir com a borda inferior do bloco abaixo.
%   A borda inferior do bloco deve coincidir com a borda superior do bloco acima.
% 
% 8- Bordas na Última Coluna ((P + 1) mod C = 0, C - 1 < P < L * C - 1)
%   A borda direita do bloco deve coincidir com a borda esquerda do bloco à esquerda.
%   A borda superior do bloco deve coincidir com a borda inferior do bloco abaixo.
%   A borda inferior do bloco deve coincidir com a borda superior do bloco acima.


%% jogo_solucao(+JogoInicial, ?JogoFinal) is semidet
%
%  Verdadeiro se JogoInicial é uma estrutura jogo(L, C, Blocos) e JogoFinal é
%  uma estrutura jogo(L, C, Solucao), onde Solucao é uma solução válida para o
%  JogoInicial, isto é, os blocos que aparecem em Solucao são os mesmos de
%  Blocos e estão em posições adequadas.

jogo_solucao(JogoInicial, JogoFinal) :-
    jogo(L, C, Blocos) = JogoInicial,
    jogo(L, C, Solucao) = JogoFinal,
    blocos_adequados(JogoFinal),
    permutation(Blocos, Solucao).

:- begin_tests(pequeno).

test(j1x1, [nondet, Final = Blocos]) :-
    Blocos = [
        bloco(3, 6, 7, 5)
    ],
    reverse(Blocos, Inicial),
    jogo_solucao(jogo(1, 1, Inicial), jogo(1, 1, Final)).


test(j2x2, [nondet, Final = Blocos]) :-
    Blocos = [
        bloco(3, 4, 7, 9),
        bloco(6, 9, 5, 4),
        bloco(7, 6, 5, 2),
        bloco(5, 3, 1, 6)
    ],
    reverse(Blocos, Inicial),
    jogo_solucao(jogo(2, 2, Inicial), jogo(2, 2, Final)).

test(j3x3, [nondet, Final = Blocos]) :-
    Blocos = [
        bloco(7, 3, 4, 9),
        bloco(3, 4, 8, 3),
        bloco(7, 4, 2, 4),
        bloco(4, 4, 8, 5),
        bloco(8, 3, 6, 4),
        bloco(2, 2, 7, 3),
        bloco(8, 9, 1, 3),
        bloco(6, 6, 6, 9),
        bloco(7, 8, 5, 6)
    ],
    reverse(Blocos, Inicial),
    jogo_solucao(jogo(3, 3, Inicial), jogo(3, 3, Final)).

:- end_tests(pequeno).


:- begin_tests(medio).

test(j4x4, [nondet, Final = Blocos]) :-
    Blocos = [
        bloco(7, 7, 4, 8),
        bloco(3, 0, 2, 7),
        bloco(7, 9, 1, 0),
        bloco(1, 6, 3, 9),
        bloco(4, 2, 5, 5),
        bloco(2, 4, 5, 2),
        bloco(1, 5, 7, 4),
        bloco(3, 8, 0, 5),
        bloco(5, 5, 8, 0),
        bloco(5, 5, 9, 5),
        bloco(7, 6, 7, 5),
        bloco(0, 2, 1, 6),
        bloco(8, 7, 9, 5),
        bloco(9, 2, 8, 7),
        bloco(7, 3, 3, 2),
        bloco(1, 0, 4, 3)
    ],
    reverse(Blocos, Inicial),
    jogo_solucao(jogo(4, 4, Inicial), jogo(4, 4, Final)).

test(j5x5, [nondet, Final = Blocos]) :-
    Blocos = [
        bloco(1, 6, 7, 5),
        bloco(4, 0, 0, 6),
        bloco(9, 2, 0, 0),
        bloco(8, 3, 5, 2),
        bloco(0, 4, 5, 3),
        bloco(7, 1, 2, 6),
        bloco(0, 4, 5, 1),
        bloco(0, 0, 3, 4),
        bloco(5, 1, 1, 0),
        bloco(5, 3, 2, 1),
        bloco(2, 9, 1, 0),
        bloco(5, 5, 5, 9),
        bloco(3, 2, 2, 5),
        bloco(1, 0, 6, 2),
        bloco(2, 9, 0, 0),
        bloco(1, 0, 7, 0),
        bloco(5, 0, 7, 0),
        bloco(2, 4, 8, 0),
        bloco(6, 9, 4, 4),
        bloco(0, 0, 6, 9),
        bloco(7, 0, 2, 5),
        bloco(7, 2, 0, 0),
        bloco(8, 6, 1, 2),
        bloco(4, 4, 6, 6),
        bloco(6, 5, 8, 4)
    ],
    reverse(Blocos, Inicial),
    jogo_solucao(jogo(5, 5, Inicial), jogo(5, 5, Final)).

test(j6x6, [nondet, Final = Blocos]) :-
    Blocos = [
        bloco(3, 0, 2, 4),
        bloco(9, 5, 5, 0),
        bloco(1, 1, 8, 5),
        bloco(4, 2, 0, 1),
        bloco(4, 3, 2, 2),
        bloco(8, 0, 0, 3),
        bloco(2, 2, 3, 9),
        bloco(5, 9, 1, 2),
        bloco(8, 2, 3, 9),
        bloco(0, 2, 3, 2),
        bloco(2, 9, 8, 2),
        bloco(0, 6, 9, 9),
        bloco(3, 1, 6, 9),
        bloco(1, 2, 2, 1),
        bloco(3, 0, 8, 2),
        bloco(3, 5, 8, 0),
        bloco(8, 7, 8, 5),
        bloco(9, 4, 8, 7),
        bloco(6, 0, 6, 9),
        bloco(2, 4, 5, 0),
        bloco(8, 7, 6, 4),
        bloco(8, 3, 7, 7),
        bloco(8, 7, 2, 3),
        bloco(8, 7, 1, 7),
        bloco(6, 3, 9, 0),
        bloco(5, 1, 9, 3),
        bloco(6, 9, 8, 1),
        bloco(7, 7, 0, 9),
        bloco(2, 0, 6, 7),
        bloco(1, 3, 7, 0),
        bloco(9, 9, 8, 7),
        bloco(9, 0, 6, 9),
        bloco(8, 1, 6, 0),
        bloco(0, 9, 7, 1),
        bloco(6, 1, 7, 9),
        bloco(7, 8, 1, 1)
    ],
    reverse(Blocos, Inicial),
    jogo_solucao(jogo(6, 6, Inicial), jogo(6, 6, Final)).

:- end_tests(medio).


:- begin_tests(grande).

test(j7x7, [nondet, Blocos = Final]) :-
    Blocos = [
        bloco(4, 1, 0, 8),
        bloco(7, 8, 1, 1),
        bloco(0, 3, 5, 8),
        bloco(4, 0, 9, 3),
        bloco(9, 7, 1, 0),
        bloco(6, 8, 3, 7),
        bloco(3, 5, 2, 8),
        bloco(0, 9, 5, 8),
        bloco(1, 4, 9, 9),
        bloco(5, 1, 6, 4),
        bloco(9, 3, 1, 1),
        bloco(1, 5, 6, 3),
        bloco(3, 3, 2, 5),
        bloco(2, 0, 4, 3),
        bloco(5, 1, 8, 8),
        bloco(9, 6, 8, 1),
        bloco(6, 5, 2, 6),
        bloco(1, 8, 6, 5),
        bloco(6, 4, 9, 8),
        bloco(2, 8, 2, 4),
        bloco(4, 1, 8, 8),
        bloco(8, 1, 5, 4),
        bloco(8, 2, 0, 1),
        bloco(2, 0, 2, 2),
        bloco(6, 4, 8, 0),
        bloco(9, 7, 7, 4),
        bloco(2, 8, 5, 7),
        bloco(8, 0, 7, 8),
        bloco(5, 6, 0, 8),
        bloco(0, 9, 4, 6),
        bloco(2, 2, 2, 9),
        bloco(8, 9, 5, 2),
        bloco(7, 1, 5, 9),
        bloco(5, 2, 0, 1),
        bloco(7, 9, 6, 2),
        bloco(0, 7, 5, 8),
        bloco(4, 7, 5, 7),
        bloco(2, 9, 1, 7),
        bloco(5, 7, 5, 9),
        bloco(5, 5, 4, 7),
        bloco(0, 8, 5, 5),
        bloco(6, 8, 7, 8),
        bloco(5, 7, 9, 6),
        bloco(5, 0, 2, 7),
        bloco(1, 4, 6, 0),
        bloco(5, 3, 2, 4),
        bloco(4, 9, 6, 3),
        bloco(5, 8, 1, 9),
        bloco(7, 8, 0, 8)
    ],
    reverse(Blocos, Inicial),
    jogo_solucao(jogo(7, 7, Inicial), jogo(7, 7, Final)).

:- end_tests(grande).


%% blocos_adequados(?Jogo) is semidet
%
%  Verdadeiro se Jogo é uma estrutura jogo(L, C, Blocos), e todos os blocos de
%  Blocos estão em posições adequadas.
% 
% Exemplos
:- begin_tests(blocos_adequados).
test(blocos_adequados) :-
    blocos_adequados(jogo(3,3,[bloco(7, 3, 4, 9),
                               bloco(3, 4, 8, 3),
                               bloco(7, 4, 2, 4),
                               bloco(4, 4, 8, 5),
                               bloco(8, 3, 6, 4),
                               bloco(2, 2, 7, 3),
                               bloco(8, 9, 1, 3),
                               bloco(6, 6, 6, 9),
                               bloco(7, 8, 5, 6)])).

test(blocos_adequados_fail, [fail]) :-
    blocos_adequados(jogo(3,3,[bloco(2,0,2,2),
                               bloco(2,2,2,2),
                               bloco(2,2,2,2),
                               bloco(2,2,2,2),
                               bloco(1,2,3,4),
                               bloco(1,1,1,1),
                               bloco(2,2,2,2),
                               bloco(2,2,2,2),
                               bloco(2,211,2,2)])).
:-end_tests(blocos_adequados).

 
% Verdadeiro se Blocos é vazio
blocos_adequados(jogo(_, _, [])).

% Verdadeiro se Blocos possui somente um elemento
blocos_adequados(jogo(1, 1, _)).

% Verdadeiro se todos os blocos sao adequados
blocos_adequados(Jogo) :-
    blocos_adequados(Jogo, 0).

blocos_adequados(Jogo, P) :-
    jogo(L, C, _) = Jogo,
    P #>= L * C, !.

blocos_adequados(Jogo, P) :-
    bloco_adequado(Jogo, P),
    P0 #= P + 1,
    blocos_adequados(Jogo, P0).


%% bloco_adequado(?Jogo, ?P) is semidet
%
%  Verdadeiro se Jogo é uma estrutura jogo(L, C, Blocos), e o bloco na posição
%  P de Blocos está em uma posição adequada.
% 
% Exemplos

:- begin_tests(bloco_adequado).

test(bloco_adequado_meio) :-
    bloco_adequado(jogo(3,3,[bloco(0,0,0,0),bloco(0,0,1,0),bloco(0,0,0,0),
                             bloco(0,4,0,0),bloco(1,2,3,4),bloco(0,0,0,2),
                             bloco(0,0,0,0),bloco(3,0,0,0),bloco(0,0,0,0)]),5).

test(bloco_adequado_canto_esquerdo_superior) :-
    bloco_adequado(jogo(3,3,[bloco(1,2,3,4),bloco(0,0,0,2),bloco(0,0,0,0),
                             bloco(3,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0),
                             bloco(0,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0)]),1).

test(bloco_adequado_canto_direito_superior) :-
    bloco_adequado(jogo(3,3,[bloco(0,0,0,0),bloco(0,4,0,0),bloco(1,2,3,4),
                             bloco(0,0,0,0),bloco(0,0,0,0),bloco(3,0,0,0),
                             bloco(0,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0)]),3).


test(bloco_adequado_canto_esquerdo_inferior) :-
    bloco_adequado(jogo(3,3,[bloco(0,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0),
                             bloco(0,0,1,0),bloco(0,0,0,0),bloco(0,0,0,0),
                             bloco(1,2,3,4),bloco(0,0,0,2),bloco(0,0,0,0)]),7).

test(bloco_adequado_meio_primeira_linha) :-
    bloco_adequado(jogo(3,3,[bloco(0,4,0,0),bloco(1,2,3,4),bloco(0,0,0,2),
                             bloco(0,0,0,0),bloco(3,0,0,0),bloco(0,0,0,0),
                             bloco(0,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0)]),2).

test(bloco_adequado_meio_ultima_linha) :-
    bloco_adequado(jogo(3,3,[bloco(0,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0),
                             bloco(0,0,0,0),bloco(0,0,1,0),bloco(0,0,0,0),
                             bloco(0,4,0,0),bloco(1,2,3,4),bloco(0,0,0,2)]),8).

test(bloco_adequado_meio_primeira_coluna) :-
    bloco_adequado(jogo(3,3,[bloco(0,0,1,0),bloco(0,0,0,0),bloco(0,0,0,0),
                             bloco(1,2,3,4),bloco(0,0,0,2),bloco(0,0,0,0),
                             bloco(3,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0)]),4).

test(bloco_adequado_meio_ultima_coluna) :-
    bloco_adequado(jogo(3,3,[bloco(0,0,0,0),bloco(0,0,0,0),bloco(0,0,1,0),
                             bloco(0,0,0,0),bloco(0,4,0,0),bloco(1,2,3,4),
                             bloco(0,0,0,0),bloco(0,0,0,0),bloco(3,0,0,0)]),6).

test(bloco_adequado_meio, [fail]) :-
    bloco_adequado(jogo(3,3,[bloco(0,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0),
                             bloco(0,0,0,0),bloco(1,2,3,4),bloco(0,0,0,0),
                             bloco(0,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0)]),5).

test(bloco_inadequado_canto_esquerdo_superior, [fail]) :-
    bloco_adequado(jogo(3,3,[bloco(1,2,3,4),bloco(0,0,0,0),bloco(0,0,0,0),
                             bloco(3,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0),
                             bloco(0,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0)]),1).


test(bloco_inadequado_canto_direito_inferior, [fail]) :-
    bloco_adequado(jogo(3,3,[bloco(0,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0),
                             bloco(0,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0),
                             bloco(0,0,0,0),bloco(0,0,0,0),bloco(1,2,3,4)]),9).

test(bloco_inadequado_canto_esquerdo_inferior, [fail]) :-
    bloco_adequado(jogo(3,3,[bloco(0,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0),
                             bloco(0,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0),
                             bloco(1,2,3,4),bloco(0,0,0,0),bloco(0,0,0,0)]),7).

test(bloco_adequado_meio_primeira_linha, [fail]) :-
    bloco_adequado(jogo(3,3,[bloco(0,0,0,0),bloco(1,2,3,4),bloco(0,0,0,0),
                             bloco(0,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0),
                             bloco(0,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0)]),2).


test(bloco_inadequado_meio_primeira_coluna, [fail]) :-
    bloco_adequado(jogo(3,3,[bloco(0,0,0,0),bloco(1,2,3,4),bloco(0,0,0,0),
                             bloco(1,2,3,4),bloco(0,0,0,2),bloco(0,0,0,0),
                             bloco(3,0,0,0),bloco(0,0,0,0),bloco(0,0,0,0)]),2).

:- end_tests(bloco_adequado).


% Verdadeiro se o bloco no canto superior esquerdo de Blocos é adequado 
% para uma matriz bi-dimensional.
bloco_adequado(Jogo, 0) :-
    Jogo = jogo(_, C, Blocos),
    nth0(1, Blocos, bloco(_, _, _, X)),
    nth0(C, Blocos, bloco(Y, _, _, _)),
    nth0(0, Blocos, bloco(_, X, Y, _)), !.

% Verdadeiro se o bloco no canto superior direito de Blocos é adequado
% para uma matriz bi-dimensional.
bloco_adequado(Jogo, P) :-
    Jogo = jogo(_, C, Blocos),
    P #= C - 1,
    Esquerda #= P - 1,
    Abaixo #= P + C,
    nth0(P, Blocos, bloco(_, _, X, Y)),
    nth0(Esquerda, Blocos, bloco(_, Y, _, _)),
    nth0(Abaixo, Blocos, bloco(X, _, _, _)), !.

% Verdadeiro se o bloco no canto inferior direito de Blocos é adequado
% para uma matriz bi-dimensional.
bloco_adequado(Jogo, P) :-
    Jogo = jogo(L, C, Blocos),
    P #= (L * C - 1),
    Esquerda #= P - 1,
    Acima #= P - C,
    nth0(P, Blocos, bloco(X, _, _, Y)),
    nth0(Esquerda, Blocos, bloco(_, Y, _, _)),
    nth0(Acima, Blocos, bloco(_, _, X, _)), !.

% Verdadeiro se o bloco no canto inferior esquerdo de Blocos é adequado
% para uma matriz bi-dimensional.
bloco_adequado(Jogo, P) :-
    Jogo = jogo(L, C, Blocos),
    P #= (L * C - L),
    Direita #= P + 1,
    Acima #= P - C,
    nth0(P, Blocos, bloco(X, Y, _, _)),
    nth0(Direita, Blocos, bloco(_, _, _, Y)),
    nth0(Acima, Blocos, bloco(_, _, X, _)), !.

% Verdadeiro se um bloco qualquer na primeira linha é adequado
bloco_adequado(Jogo, P) :-
    Jogo = jogo(_, C, Blocos),
    P #< C - 1, P #> 0,
    Abaixo #= P + C,
    Esquerda #= P - 1,
    Direita #= P + 1,
    nth0(P, Blocos, bloco(_, X, Y, Z)),
    nth0(Abaixo, Blocos, bloco(Y, _, _, _)),
    nth0(Esquerda, Blocos, bloco(_, Z, _, _)),
    nth0(Direita, Blocos, bloco(_, _, _, X)), !.

% Verdadeiro se um bloco qualquer na última linha é adequado
bloco_adequado(Jogo, P) :-
    Jogo = jogo(L, C, Blocos),
    P #< (L * C - 1), P #> (L * C - L),
    Acima #= P - C,
    Esquerda #= P - 1,
    Direita #= P + 1,
    nth0(P, Blocos, bloco(X, Y, _, Z)),
    nth0(Acima, Blocos, bloco(_, _, X, _)),
    nth0(Esquerda, Blocos, bloco(_, Z, _, _)),
    nth0(Direita, Blocos, bloco(_, _, _, Y)), !.

% Verdadeiro se um bloco qualquer na primeira coluna é adequado
bloco_adequado(Jogo, P) :-
    Jogo = jogo(L, C, Blocos),
    P mod C #= 0, P #\= 0, P #\= (L * C - L),
    Acima #= P - C,
    Abaixo #= P + C,
    Direita #= P + 1,
    nth0(P, Blocos, bloco(X, Y, Z, _)),
    nth0(Acima, Blocos, bloco(_, _, X, _)),
    nth0(Abaixo, Blocos, bloco(Z, _, _, _)),
    nth0(Direita, Blocos, bloco(_, _, _, Y)), !.

% Verdadeiro se um bloco qualquer na última coluna é adequado
bloco_adequado(Jogo, P) :-
    Jogo = jogo(L, C, Blocos),
    (P + 1) mod C #= 0, P #\= C - 1, P #\= (L * C - 1),
    Acima #= P - C,
    Abaixo #= P + C,
    Esquerda #= P - 1,
    nth0(P, Blocos, bloco(X, _, Y, Z)),
    nth0(Acima, Blocos, bloco(_, _, X, _)),
    nth0(Abaixo, Blocos, bloco(Y, _, _, _)),
    nth0(Esquerda, Blocos, bloco(_, Z, _, _)), !.

% Verdadeiro se um bloco qualquer é adequado
bloco_adequado(Jogo, P) :-
    Jogo = jogo(_, C, Blocos),
    Acima #= P - C,
    Abaixo #= P + C,
    Esquerda #= P - 1,
    Direita #= P + 1,
    nth0(P, Blocos, bloco(X, Y, Z, A)),
    nth0(Acima, Blocos, bloco(_, _, X, _)),
    nth0(Abaixo, Blocos, bloco(Z, _, _, _)),
    nth0(Esquerda, Blocos, bloco(_, A, _, _)),
    nth0(Direita, Blocos, bloco(_, _, _, Y)).