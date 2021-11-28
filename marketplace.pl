:- dynamic(inventoryMarket/1).
inventoryMarket([
    % [nama item, harga]
    [potato_seed,40],
    [tomato_seed,50],
    [chicken,200],
    [turkey,750],
    [shovel,300],
    [bait,5],
    [good_rod,2000],
    [good_fertilizer,40]
]).

:- dynamic(lockedInventoryMarket/1).
lockedInventoryMarket([
    [carrot_seed,60, ' Unlock Lvl 3 Farming'],
    [rice_seed,70, ' Unlock Lvl 7 Farming'],
    [sheep,1500, ' Unlock Lvl 3 Ranching'],
    [cow,2000, ' Unlock Lvl 7 Ranching'],
    [rare_rod,4000, ' Unlock Lvl 3 Fishing'],
    [legend_rod,10000, ' Unlock Lvl 7 Fishing'],
    [best_fertilizer,70, ' Unlock Lvl 3 Farming'],
    [instant_fertilizer,100, ' Unlock Lvl 7 Farming']
]).

addItemMarket(Item) :-
    inventoryMarket(Invent),
    itemPrice(Item, Harga),
    append(Invent, [[Item, Harga]], NewInvent),
    retract(inventoryMarket(Invent)),
    assertz(inventoryMarket(NewInvent)).

deletelockedItemMarket(Item) :-
    lockedInventoryMarket(Invent),
    delete(Invent, [Item, _, _], NewInvent),
    retract(lockedInventoryMarket(Invent)),
    assertz(lockedInventoryMarket(NewInvent)).

unlockedItem(Item) :-
    addItemMarket(Item),
    deletelockedItemMarket(Item).

printInventoryMarket([], Number) :-
    lockedInventoryMarket(LIM),
    printLockedInventoryMarket(LIM, Number).

printInventoryMarket([[Nama, Harga]|T], Number) :-
    format('~w. ', [Number]),
    write(Nama), tab(1), format('(~w Gold)', [Harga]),
    IncNumber is Number + 1,
    nl, printInventoryMarket(T, IncNumber).

printLockedInventoryMarket([], _) :- !.
printLockedInventoryMarket([[Nama, Harga, Keterangan]|T], Number) :-
    format('~w. ', [Number]),
    write(Nama), tab(1), format('(~w Gold)', [Harga]), write(Keterangan),
    IncNumber is Number + 1,
    nl, printLockedInventoryMarket(T, IncNumber).

:- dynamic(stateMarket/1).
% dapat berupa
% 'di dalam' : ketika di market tapi belum nulis command marketplace.
% 'di luar' : ketika telah keluar dari market (exitMarket)
stateMarket('di luar').

marketplace :-
    state(not_started), !,
    write('Command tidak dikenali karena kamu belum memulai permainan').

marketplace :-
    state(free),
    playerCell(X),
    X \= 'M', !,
    write('Kamu harus berada di marketplace terlebih dahulu').

marketplace :-
    state(free),
    playerCell('M'),
    stateMarket('di dalam'), !,
    write('Kamu sudah berada di dalam pasar sayang').

marketplace :-
    state(free),
    playerCell('M'),
    stateMarket('di luar'), !,
    retractall(stateMarket(_)),
    asserta(stateMarket('di dalam')),
    gold(UangYangAda),
    write('Selamat datang di pasar sobat miskino\n'),
    format('Kamu punya uang segini : ~w\n', [UangYangAda]),
    write('Apa yang ingin kamu lakukan?\n'),
    write('- buy\n'),
    write('- sell\n').

buy :-
    % state(free),
    % stateMarket('di dalam'),
    write('Apa yang ingin kamu beli?\n'),
    inventoryMarket(InventMart),
    printInventoryMarket(InventMart, 1),
    nl.

sell :-
    state(free),
    stateMarket('di dalam'),
    write('Ini adalah daftar item yang ada di item kamu\n'),
    inventory,
    write('Apa item yang ingin kamu jual? :'), tab(2),
    read(Item),
    (
        inventory(Invent),
        (
            % Item tidak ada di dalam inventory
            \+ member([Item, _JumlahItem], Invent), !,
            write('Kami tidak dapat membeli barang tersebut karena tidak ada di inventory kamu\n')
        );
        (
            % item ada di inventory
            write('Jumlah item yang ingin dijual :'), tab(2),
            read(Qty), nl,
            jumlahBarang(Item, C),
            (
                (
                    % jumlah masukan lebih besar daripada jumlah di inventory
                    C < Qty, !,
                    format('Kamu tidak memiliki ~w sebanyak itu\n', [Item])
                );
                (
                    itemPrice(Item, Harga),
                    (
                        (
                            buyable(Item),
                            SellValue is Qty * (Harga // 2)
                        );
                        SellValue is Qty * Harga
                    ),
                    earnGold(SellValue),
                    format('Kamu menjual ~w', [Qty]),
                    format(' ~w\n', [Item]),
                    format('Kamu memperoleh ~w Gold\n', [SellValue]),
                    drop(Item, Qty)
                )
            )
        )
    ).

exitMarket :-
    stateMarket('di dalam'),
    write('Terima kasih telah berkunjung ke pasar\n'),
    retractall(stateMarket(_)),
    asserta(stateMarket('di luar')).