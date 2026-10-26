# Battle sprite import (#494–1025)

Written by `tools/sprites/convert_battle_sprites.py` from `assets/sprites/packs/gen5_9_part1`, with fronts from `assets/sprites/packs/pokeapi_fronts`. Each species' front and back have palettes of their own, 15 colours each (`normal.pal`/`shiny.pal` for the front, `back_normal.pal`/`back_shiny.pal` for the back); **Colours** is how many the source front / back had, as the DS stores them (5 bits a channel; more than 15 were reduced). A shiny sprite is the same picture with a second palette; **Shiny** is the share of the shiny front / back that the shiny palette colours as the source has it (a shiny that is more than a change of colours can't all fit, nor one drawn apart from its front). Notes list art scaled down to fit 80×80, art cleared from the top-left corner and shinies that didn't line up. These are the sprites to look at first in game.

| Dex | Pokémon | Result | Colours | Shiny | Notes |
|---|---|---|---|---|---|
| 494 | Victini | converted | 15 / 8 | 100% / 100% |  |
| 495 | Snivy | converted | 13 / 13 | 100% / 100% |  |
| 496 | Servine | converted | 12 / 11 | 100% / 100% |  |
| 497 | Serperior | converted | 14 / 14 | 100% / 100% |  |
| 498 | Tepig | converted | 12 / 12 | 100% / 100% |  |
| 499 | Pignite | converted | 14 / 11 | 100% / 100% |  |
| 500 | Emboar | converted | 15 / 13 | 100% / 100% |  |
| 501 | Oshawott | converted | 14 / 11 | 100% / 100% |  |
| 502 | Dewott | converted | 14 / 12 | 100% / 100% |  |
| 503 | Samurott | converted | 14 / 11 | 100% / 100% | front: 1 pixel(s) in the top-left corner cleared |
| 504 | Patrat | converted | 15 / 8 | 100% / 100% |  |
| 505 | Watchog | converted | 15 / 9 | 100% / 100% |  |
| 506 | Lillipup | converted | 13 / 9 | 100% / 100% |  |
| 507 | Herdier | converted | 14 / 10 | 100% / 100% |  |
| 508 | Stoutland | converted | 15 / 10 | 100% / 100% |  |
| 509 | Purrloin | converted | 13 / 6 | 100% / 100% |  |
| 510 | Liepard | converted | 14 / 13 | 100% / 100% |  |
| 511 | Pansage | converted | 15 / 8 | 100% / 100% |  |
| 512 | Simisage | converted | 13 / 11 | 100% / 100% |  |
| 513 | Pansear | converted | 13 / 7 | 100% / 100% |  |
| 514 | Simisear | converted | 13 / 11 | 100% / 100% |  |
| 515 | Panpour | converted | 12 / 9 | 100% / 100% |  |
| 516 | Simipour | converted | 14 / 10 | 100% / 100% |  |
| 517 | Munna | converted | 14 / 11 | 100% / 100% |  |
| 518 | Musharna | converted | 12 / 10 | 100% / 100% |  |
| 519 | Pidove | converted | 15 / 15 | 100% / 100% |  |
| 520 | Tranquill | converted | 15 / 11 | 100% / 100% |  |
| 521 | Unfezant | converted | 15 / 14 | 100% / 100% |  |
| 522 | Blitzle | converted | 13 / 13 | 100% / 100% |  |
| 523 | Zebstrika | converted | 14 / 11 | 100% / 100% |  |
| 524 | Roggenrola | converted | 10 / 7 | 100% / 100% |  |
| 525 | Boldore | converted | 11 / 8 | 100% / 100% |  |
| 526 | Gigalith | converted | 13 / 9 | 100% / 100% |  |
| 527 | Woobat | converted | 15 / 7 | 100% / 100% |  |
| 528 | Swoobat | converted | 14 / 8 | 100% / 100% | front scaled to 84% |
| 529 | Drilbur | converted | 14 / 11 | 100% / 100% |  |
| 530 | Excadrill | converted | 14 / 12 | 100% / 100% |  |
| 531 | Audino | converted | 12 / 11 | 100% / 100% |  |
| 532 | Timburr | converted | 15 / 14 | 100% / 100% |  |
| 533 | Gurdurr | converted | 14 / 10 | 100% / 100% |  |
| 534 | Conkeldurr | converted | 13 / 15 | 100% / 100% | front scaled to 98% |
| 535 | Tympole | converted | 12 / 8 | 100% / 100% |  |
| 536 | Palpitoad | converted | 15 / 10 | 100% / 100% |  |
| 537 | Seismitoad | converted | 13 / 10 | 100% / 100% |  |
| 538 | Throh | converted | 10 / 9 | 100% / 100% |  |
| 539 | Sawk | converted | 13 / 11 | 100% / 100% |  |
| 540 | Sewaddle | converted | 14 / 8 | 100% / 100% |  |
| 541 | Swadloon | converted | 12 / 7 | 100% / 100% |  |
| 542 | Leavanny | converted | 14 / 10 | 100% / 100% |  |
| 543 | Venipede | converted | 14 / 13 | 100% / 100% |  |
| 544 | Whirlipede | converted | 14 / 13 | 100% / 100% |  |
| 545 | Scolipede | converted | 13 / 11 | 100% / 100% | front scaled to 90% |
| 546 | Cottonee | converted | 12 / 8 | 100% / 100% |  |
| 547 | Whimsicott | converted | 15 / 8 | 100% / 100% |  |
| 548 | Petilil | converted | 11 / 7 | 100% / 100% |  |
| 549 | Lilligant | converted | 15 / 14 | 100% / 100% |  |
| 550 | Basculin | converted | 12 / 11 | 100% / 100% |  |
| 551 | Sandile | converted | 10 / 7 | 100% / 100% |  |
| 552 | Krokorok | converted | 13 / 11 | 100% / 100% |  |
| 553 | Krookodile | converted | 14 / 9 | 100% / 100% |  |
| 554 | Darumaka | converted | 14 / 10 | 100% / 100% |  |
| 555 | Darmanitan | converted | 15 / 11 | 100% / 100% |  |
| 556 | Maractus | converted | 12 / 12 | 100% / 100% |  |
| 557 | Dwebble | converted | 12 / 11 | 100% / 100% |  |
| 558 | Crustle | converted | 13 / 6 | 100% / 100% |  |
| 559 | Scraggy | converted | 14 / 14 | 100% / 100% |  |
| 560 | Scrafty | converted | 15 / 13 | 100% / 100% |  |
| 561 | Sigilyph | converted | 13 / 12 | 100% / 100% | front scaled to 88% |
| 562 | Yamask | converted | 11 / 8 | 100% / 100% |  |
| 563 | Cofagrigus | converted | 13 / 9 | 100% / 100% | front scaled to 88% |
| 564 | Tirtouga | converted | 11 / 7 | 100% / 100% |  |
| 565 | Carracosta | converted | 12 / 11 | 100% / 100% |  |
| 566 | Archen | converted | 13 / 13 | 100% / 100% |  |
| 567 | Archeops | converted | 15 / 14 | 100% / 100% | front scaled to 95% |
| 568 | Trubbish | converted | 14 / 11 | 100% / 100% |  |
| 569 | Garbodor | converted | 14 / 9 | 100% / 100% | front scaled to 98% |
| 570 | Zorua | converted | 10 / 7 | 100% / 100% |  |
| 571 | Zoroark | converted | 13 / 11 | 100% / 100% |  |
| 572 | Minccino | converted | 9 / 6 | 100% / 100% |  |
| 573 | Cinccino | converted | 10 / 10 | 100% / 100% |  |
| 574 | Gothita | converted | 13 / 9 | 100% / 100% |  |
| 575 | Gothorita | converted | 13 / 6 | 100% / 100% |  |
| 576 | Gothitelle | converted | 14 / 9 | 100% / 100% |  |
| 577 | Solosis | converted | 15 / 13 | 100% / 100% |  |
| 578 | Duosion | converted | 11 / 9 | 100% / 100% |  |
| 579 | Reuniclus | converted | 14 / 12 | 100% / 100% | front scaled to 91% |
| 580 | Ducklett | converted | 11 / 10 | 100% / 100% |  |
| 581 | Swanna | converted | 14 / 13 | 100% / 100% |  |
| 582 | Vanillite | converted | 14 / 10 | 100% / 100% |  |
| 583 | Vanillish | converted | 13 / 10 | 100% / 100% |  |
| 584 | Vanilluxe | converted | 13 / 10 | 100% / 100% |  |
| 585 | Deerling | converted | 14 / 14 | 100% / 100% |  |
| 586 | Sawsbuck | converted | 14 / 12 | 100% / 100% |  |
| 587 | Emolga | converted | 15 / 10 | 100% / 100% |  |
| 588 | Karrablast | converted | 14 / 7 | 100% / 100% |  |
| 589 | Escavalier | converted | 14 / 12 | 100% / 100% |  |
| 590 | Foongus | converted | 11 / 8 | 100% / 100% |  |
| 591 | Amoonguss | converted | 13 / 9 | 100% / 100% |  |
| 592 | Frillish | converted | 15 / 7 | 100% / 100% |  |
| 593 | Jellicent | converted | 14 / 7 | 100% / 100% |  |
| 594 | Alomomola | converted | 15 / 12 | 100% / 100% |  |
| 595 | Joltik | converted | 9 / 4 | 100% / 100% |  |
| 596 | Galvantula | converted | 12 / 11 | 100% / 100% |  |
| 597 | Ferroseed | converted | 12 / 10 | 100% / 100% |  |
| 598 | Ferrothorn | converted | 11 / 8 | 100% / 100% |  |
| 599 | Klink | converted | 9 / 8 | 100% / 100% |  |
| 600 | Klang | converted | 12 / 10 | 100% / 100% |  |
| 601 | Klinklang | converted | 15 / 11 | 100% / 100% |  |
| 602 | Tynamo | converted | 11 / 8 | 100% / 100% |  |
| 603 | Eelektrik | converted | 13 / 12 | 100% / 100% |  |
| 604 | Eelektross | converted | 14 / 14 | 100% / 100% |  |
| 605 | Elgyem | converted | 14 / 9 | 100% / 100% |  |
| 606 | Beheeyem | converted | 15 / 12 | 100% / 100% |  |
| 607 | Litwick | converted | 11 / 9 | 100% / 100% |  |
| 608 | Lampent | converted | 11 / 8 | 100% / 100% |  |
| 609 | Chandelure | converted | 10 / 9 | 100% / 100% |  |
| 610 | Axew | converted | 14 / 14 | 100% / 100% |  |
| 611 | Fraxure | converted | 15 / 12 | 100% / 100% |  |
| 612 | Haxorus | converted | 13 / 9 | 100% / 100% | front scaled to 94% |
| 613 | Cubchoo | converted | 13 / 13 | 100% / 100% |  |
| 614 | Beartic | converted | 10 / 7 | 100% / 100% |  |
| 615 | Cryogonal | converted | 14 / 10 | 100% / 100% |  |
| 616 | Shelmet | converted | 13 / 10 | 100% / 100% |  |
| 617 | Accelgor | converted | 13 / 12 | 100% / 100% |  |
| 618 | Stunfisk | converted | 15 / 12 | 100% / 100% |  |
| 619 | Mienfoo | converted | 12 / 11 | 100% / 100% |  |
| 620 | Mienshao | converted | 15 / 13 | 100% / 100% |  |
| 621 | Druddigon | converted | 15 / 13 | 100% / 100% | front scaled to 99% |
| 622 | Golett | converted | 13 / 13 | 100% / 100% |  |
| 623 | Golurk | converted | 13 / 9 | 100% / 100% |  |
| 624 | Pawniard | converted | 13 / 9 | 100% / 100% |  |
| 625 | Bisharp | converted | 15 / 13 | 100% / 100% |  |
| 626 | Bouffalant | converted | 15 / 10 | 100% / 100% |  |
| 627 | Rufflet | converted | 13 / 9 | 100% / 100% |  |
| 628 | Braviary | converted | 15 / 14 | 100% / 100% | front scaled to 91% |
| 629 | Vullaby | converted | 13 / 11 | 100% / 100% |  |
| 630 | Mandibuzz | converted | 15 / 14 | 100% / 100% |  |
| 631 | Heatmor | converted | 11 / 10 | 100% / 100% |  |
| 632 | Durant | converted | 9 / 9 | 100% / 100% |  |
| 633 | Deino | converted | 12 / 10 | 100% / 100% |  |
| 634 | Zweilous | converted | 13 / 7 | 100% / 100% |  |
| 635 | Hydreigon | converted | 13 / 10 | 100% / 100% |  |
| 636 | Larvesta | converted | 15 / 13 | 100% / 100% |  |
| 637 | Volcarona | converted | 15 / 12 | 100% / 100% |  |
| 638 | Cobalion | converted | 15 / 14 | 100% / 100% |  |
| 639 | Terrakion | converted | 15 / 13 | 100% / 100% |  |
| 640 | Virizion | converted | 14 / 12 | 100% / 100% |  |
| 641 | Tornadus | converted | 14 / 13 | 100% / 100% |  |
| 642 | Thundurus | converted | 15 / 13 | 100% / 100% |  |
| 643 | Reshiram | converted | 6 / 6 | 100% / 100% | front scaled to 83% |
| 644 | Zekrom | converted | 12 / 9 | 100% / 100% | front scaled to 84% |
| 645 | Landorus | converted | 14 / 13 | 100% / 100% |  |
| 646 | Kyurem | converted | 13 / 13 | 100% / 100% | front scaled to 85% |
| 647 | Keldeo | converted | 15 / 15 | 100% / 100% |  |
| 648 | Meloetta | converted | 15 / 13 | 100% / 100% |  |
| 649 | Genesect | converted | 14 / 13 | 100% / 100% |  |
| 650 | Chespin | converted | 11 / 10 | 100% / 100% |  |
| 651 | Quilladin | converted | 14 / 12 | 100% / 100% |  |
| 652 | Chesnaught | converted | 14 / 13 | 100% / 100% | front scaled to 89% |
| 653 | Fennekin | converted | 11 / 10 | 100% / 100% |  |
| 654 | Braixen | converted | 13 / 12 | 100% / 100% |  |
| 655 | Delphox | converted | 15 / 14 | 100% / 100% | front scaled to 90% |
| 656 | Froakie | converted | 10 / 8 | 100% / 100% |  |
| 657 | Frogadier | converted | 12 / 12 | 100% / 100% |  |
| 658 | Greninja | converted | 15 / 15 | 100% / 100% |  |
| 659 | Bunnelby | converted | 12 / 7 | 100% / 100% |  |
| 660 | Diggersby | converted | 12 / 9 | 100% / 100% |  |
| 661 | Fletchling | converted | 11 / 13 | 100% / 100% |  |
| 662 | Fletchinder | converted | 14 / 13 | 100% / 100% |  |
| 663 | Talonflame | converted | 11 / 11 | 100% / 100% | front scaled to 89%; back scaled to 88%; back: 2 pixel(s) in the top-left corner cleared |
| 664 | Scatterbug | converted | 10 / 8 | 100% / 100% |  |
| 665 | Spewpa | converted | 13 / 12 | 100% / 100% |  |
| 666 | Vivillon | converted | 19 / 14 | 42% / 100% | shiny front doesn't line up (40% of pixels) |
| 667 | Litleo | converted | 11 / 9 | 100% / 100% |  |
| 668 | Pyroar | converted | 26 / 13 | 68% / 100% | shiny front doesn't line up (18% of pixels) |
| 669 | Flabébé | converted | 13 / 14 | 40% / 100% | shiny front doesn't line up (46% of pixels) |
| 670 | Floette | converted | 13 / 14 | 41% / 100% | shiny front doesn't line up (55% of pixels) |
| 671 | Florges | converted | 15 / 15 | 55% / 100% | shiny front doesn't line up (31% of pixels) |
| 672 | Skiddo | converted | 14 / 14 | 100% / 100% |  |
| 673 | Gogoat | converted | 14 / 14 | 100% / 100% |  |
| 674 | Pancham | converted | 10 / 8 | 100% / 100% |  |
| 675 | Pangoro | converted | 10 / 9 | 100% / 100% |  |
| 676 | Furfrou | converted | 9 / 9 | 99% / 100% | shiny front moved (+1, +1) to line up |
| 677 | Espurr | converted | 9 / 6 | 100% / 100% |  |
| 678 | Meowstic | converted | 10 / 7 | 100% / 100% |  |
| 679 | Honedge | converted | 15 / 15 | 100% / 100% |  |
| 680 | Doublade | converted | 16 / 15 | 98% / 100% |  |
| 681 | Aegislash | converted | 15 / 14 | 100% / 100% |  |
| 682 | Spritzee | converted | 13 / 10 | 100% / 100% |  |
| 683 | Aromatisse | converted | 15 / 8 | 100% / 100% |  |
| 684 | Swirlix | converted | 9 / 6 | 100% / 100% |  |
| 685 | Slurpuff | converted | 11 / 11 | 100% / 100% |  |
| 686 | Inkay | converted | 15 / 14 | 100% / 100% |  |
| 687 | Malamar | converted | 13 / 14 | 100% / 100% | front scaled to 93% |
| 688 | Binacle | converted | 13 / 12 | 100% / 100% |  |
| 689 | Barbaracle | converted | 15 / 13 | 100% / 100% | front scaled to 93% |
| 690 | Skrelp | converted | 12 / 12 | 100% / 100% |  |
| 691 | Dragalge | converted | 14 / 14 | 100% / 100% | front scaled to 86% |
| 692 | Clauncher | converted | 11 / 11 | 100% / 100% |  |
| 693 | Clawitzer | converted | 13 / 12 | 100% / 100% | front scaled to 92% |
| 694 | Helioptile | converted | 11 / 8 | 100% / 100% |  |
| 695 | Heliolisk | converted | 15 / 13 | 100% / 100% |  |
| 696 | Tyrunt | converted | 10 / 10 | 100% / 100% |  |
| 697 | Tyrantrum | converted | 12 / 12 | 100% / 100% | front scaled to 87%; back scaled to 87% |
| 698 | Amaura | converted | 12 / 12 | 100% / 100% |  |
| 699 | Aurorus | converted | 15 / 18 | 100% / 97% | front scaled to 93% |
| 700 | Sylveon | converted | 12 / 11 | 100% / 100% |  |
| 701 | Hawlucha | converted | 15 / 15 | 100% / 100% |  |
| 702 | Dedenne | converted | 11 / 7 | 100% / 100% |  |
| 703 | Carbink | converted | 13 / 11 | 100% / 100% |  |
| 704 | Goomy | converted | 10 / 10 | 100% / 100% |  |
| 705 | Sliggoo | converted | 13 / 12 | 100% / 100% |  |
| 706 | Goodra | converted | 15 / 13 | 100% / 100% |  |
| 707 | Klefki | converted | 15 / 15 | 100% / 100% |  |
| 708 | Phantump | converted | 10 / 8 | 100% / 100% |  |
| 709 | Trevenant | converted | 11 / 9 | 100% / 100% | front scaled to 94% |
| 710 | Pumpkaboo | converted | 10 / 8 | 100% / 100% |  |
| 711 | Gourgeist | converted | 14 / 9 | 100% / 100% |  |
| 712 | Bergmite | converted | 13 / 9 | 100% / 100% |  |
| 713 | Avalugg | converted | 13 / 12 | 100% / 100% | front scaled to 96% |
| 714 | Noibat | converted | 12 / 11 | 100% / 100% |  |
| 715 | Noivern | converted | 15 / 13 | 100% / 100% | front scaled to 83% |
| 716 | Xerneas | converted | 9 / 8 | 98% / 100% | front scaled to 83% |
| 717 | Yveltal | converted | 13 / 12 | 100% / 100% | front scaled to 83% |
| 718 | Zygarde | converted | 10 / 9 | 100% / 100% | front scaled to 91% |
| 719 | Diancie | converted | 14 / 12 | 100% / 100% |  |
| 720 | Hoopa | converted | 15 / 14 | 100% / 100% |  |
| 721 | Volcanion | converted | 15 / 10 | 100% / 100% | front scaled to 94% |
| 722 | Rowlet | converted | 14 / 12 | 100% / 100% |  |
| 723 | Dartrix | converted | 13 / 14 | 100% / 100% |  |
| 724 | Decidueye | converted | 15 / 13 | 100% / 100% |  |
| 725 | Litten | converted | 12 / 7 | 100% / 100% |  |
| 726 | Torracat | converted | 11 / 9 | 100% / 100% |  |
| 727 | Incineroar | converted | 14 / 11 | 100% / 100% | front scaled to 94%; back scaled to 95% |
| 728 | Popplio | converted | 14 / 13 | 100% / 100% |  |
| 729 | Brionne | converted | 14 / 13 | 100% / 100% |  |
| 730 | Primarina | converted | 15 / 14 | 100% / 100% |  |
| 731 | Pikipek | converted | 8 / 7 | 100% / 100% |  |
| 732 | Trumbeak | converted | 14 / 14 | 100% / 100% |  |
| 733 | Toucannon | converted | 12 / 12 | 100% / 100% |  |
| 734 | Yungoos | converted | 12 / 8 | 100% / 100% |  |
| 735 | Gumshoos | converted | 13 / 9 | 100% / 100% |  |
| 736 | Grubbin | converted | 12 / 10 | 100% / 100% |  |
| 737 | Charjabug | converted | 13 / 8 | 100% / 100% |  |
| 738 | Vikavolt | converted | 13 / 12 | 100% / 100% |  |
| 739 | Crabrawler | converted | 13 / 12 | 100% / 100% |  |
| 740 | Crabominable | converted | 15 / 12 | 100% / 100% | front scaled to 85%; back scaled to 86% |
| 741 | Oricorio | converted | 14 / 13 | 100% / 100% |  |
| 742 | Cutiefly | converted | 9 / 9 | 100% / 100% |  |
| 743 | Ribombee | converted | 10 / 10 | 100% / 100% |  |
| 744 | Rockruff | converted | 13 / 10 | 100% / 100% |  |
| 745 | Lycanroc | converted | 14 / 10 | 100% / 100% |  |
| 746 | Wishiwashi | converted | 15 / 11 | 100% / 100% |  |
| 747 | Mareanie | converted | 12 / 10 | 100% / 100% |  |
| 748 | Toxapex | converted | 15 / 13 | 100% / 100% | front scaled to 90%; back scaled to 90% |
| 749 | Mudbray | converted | 13 / 11 | 100% / 100% |  |
| 750 | Mudsdale | converted | 11 / 11 | 100% / 100% |  |
| 751 | Dewpider | converted | 12 / 13 | 100% / 100% |  |
| 752 | Araquanid | converted | 15 / 14 | 100% / 100% |  |
| 753 | Fomantis | converted | 14 / 12 | 100% / 100% |  |
| 754 | Lurantis | converted | 12 / 11 | 100% / 100% |  |
| 755 | Morelull | converted | 13 / 14 | 100% / 100% |  |
| 756 | Shiinotic | converted | 13 / 14 | 100% / 100% |  |
| 757 | Salandit | converted | 14 / 14 | 100% / 100% |  |
| 758 | Salazzle | converted | 12 / 12 | 100% / 100% |  |
| 759 | Stufful | converted | 12 / 11 | 100% / 100% |  |
| 760 | Bewear | converted | 10 / 10 | 100% / 100% |  |
| 761 | Bounsweet | converted | 11 / 10 | 100% / 100% |  |
| 762 | Steenee | converted | 13 / 12 | 100% / 100% |  |
| 763 | Tsareena | converted | 14 / 13 | 100% / 100% |  |
| 764 | Comfey | converted | 15 / 14 | 100% / 100% |  |
| 765 | Oranguru | converted | 14 / 14 | 100% / 100% |  |
| 766 | Passimian | converted | 13 / 10 | 100% / 100% |  |
| 767 | Wimpod | converted | 11 / 9 | 100% / 100% |  |
| 768 | Golisopod | converted | 13 / 14 | 100% / 100% | front scaled to 99% |
| 769 | Sandygast | converted | 10 / 10 | 100% / 100% |  |
| 770 | Palossand | converted | 11 / 11 | 100% / 100% |  |
| 771 | Pyukumuku | converted | 11 / 10 | 100% / 100% |  |
| 772 | Type: Null | converted | 14 / 14 | 100% / 100% |  |
| 773 | Silvally | converted | 14 / 10 | 100% / 100% | front scaled to 96% |
| 774 | Minior | converted | 10 / 11 | 100% / 100% |  |
| 775 | Komala | converted | 14 / 14 | 100% / 100% |  |
| 776 | Turtonator | converted | 14 / 13 | 100% / 100% |  |
| 777 | Togedemaru | converted | 11 / 10 | 100% / 100% |  |
| 778 | Mimikyu | converted | 10 / 9 | 100% / 100% |  |
| 779 | Bruxish | converted | 14 / 14 | 100% / 100% |  |
| 780 | Drampa | converted | 15 / 9 | 100% / 100% | back scaled to 98% |
| 781 | Dhelmise | converted | 15 / 14 | 100% / 100% | back scaled to 99% |
| 782 | Jangmo-o | converted | 13 / 12 | 100% / 100% |  |
| 783 | Hakamo-o | converted | 13 / 13 | 100% / 100% |  |
| 784 | Kommo-o | converted | 15 / 13 | 100% / 100% | front scaled to 99%; back scaled to 87% |
| 785 | Tapu Koko | converted | 14 / 13 | 100% / 100% |  |
| 786 | Tapu Lele | converted | 14 / 12 | 100% / 100% |  |
| 787 | Tapu Bulu | converted | 13 / 12 | 100% / 100% |  |
| 788 | Tapu Fini | converted | 14 / 13 | 100% / 100% |  |
| 789 | Cosmog | converted | 15 / 14 | 100% / 100% |  |
| 790 | Cosmoem | converted | 14 / 13 | 100% / 100% |  |
| 791 | Solgaleo | converted | 15 / 14 | 100% / 100% | front scaled to 94% |
| 792 | Lunala | converted | 14 / 12 | 100% / 100% | front scaled to 91% |
| 793 | Nihilego | converted | 9 / 9 | 100% / 100% |  |
| 794 | Buzzwole | converted | 15 / 15 | 100% / 100% | front scaled to 83%; back scaled to 83% |
| 795 | Pheromosa | converted | 15 / 11 | 100% / 100% | front scaled to 87%; back scaled to 87% |
| 796 | Xurkitree | converted | 14 / 15 | 100% / 100% | front scaled to 83%; back scaled to 84% |
| 797 | Celesteela | converted | 12 / 12 | 100% / 100% | front scaled to 83%; back scaled to 83% |
| 798 | Kartana | converted | 13 / 12 | 100% / 100% |  |
| 799 | Guzzlord | converted | 13 / 7 | 100% / 100% | front scaled to 83%; back scaled to 83% |
| 800 | Necrozma | converted | 11 / 8 | 100% / 100% | front scaled to 92% |
| 801 | Magearna | converted | 15 / 13 | 100% / 100% |  |
| 802 | Marshadow | converted | 10 / 4 | 100% / 100% |  |
| 803 | Poipole | converted | 13 / 10 | 100% / 100% |  |
| 804 | Naganadel | converted | 14 / 14 | 100% / 100% | front scaled to 92%; back scaled to 92% |
| 805 | Stakataka | converted | 11 / 9 | 100% / 100% | front scaled to 85%; back scaled to 85% |
| 806 | Blacephalon | converted | 13 / 14 | 100% / 100% |  |
| 807 | Zeraora | converted | 12 / 12 | 100% / 100% | shiny front moved (+1, -1) to line up |
| 808 | Meltan | converted | 15 / 14 | 100% / 100% |  |
| 809 | Melmetal | converted | 14 / 9 | 100% / 100% | front scaled to 83% |
| 810 | Grookey | converted | 15 / 10 | 100% / 100% |  |
| 811 | Thwackey | converted | 15 / 12 | 100% / 100% |  |
| 812 | Rillaboom | converted | 15 / 13 | 100% / 100% | front scaled to 99% |
| 813 | Scorbunny | converted | 12 / 8 | 100% / 100% |  |
| 814 | Raboot | converted | 13 / 10 | 100% / 100% |  |
| 815 | Cinderace | converted | 13 / 13 | 100% / 100% |  |
| 816 | Sobble | converted | 14 / 9 | 100% / 100% |  |
| 817 | Drizzile | converted | 14 / 14 | 100% / 100% |  |
| 818 | Inteleon | converted | 14 / 13 | 100% / 100% |  |
| 819 | Skwovet | converted | 12 / 9 | 100% / 100% |  |
| 820 | Greedent | converted | 14 / 7 | 100% / 100% |  |
| 821 | Rookidee | converted | 15 / 10 | 100% / 100% |  |
| 822 | Corvisquire | converted | 14 / 10 | 100% / 100% |  |
| 823 | Corviknight | converted | 13 / 13 | 100% / 100% |  |
| 824 | Blipbug | converted | 13 / 12 | 100% / 100% |  |
| 825 | Dottler | converted | 14 / 8 | 100% / 100% |  |
| 826 | Orbeetle | converted | 15 / 8 | 100% / 100% |  |
| 827 | Nickit | converted | 10 / 8 | 100% / 100% |  |
| 828 | Thievul | converted | 12 / 11 | 100% / 100% | front scaled to 99%; back scaled to 99% |
| 829 | Gossifleur | converted | 14 / 11 | 100% / 100% |  |
| 830 | Eldegoss | converted | 14 / 8 | 100% / 100% |  |
| 831 | Wooloo | converted | 15 / 14 | 100% / 100% |  |
| 832 | Dubwool | converted | 15 / 12 | 100% / 100% |  |
| 833 | Chewtle | converted | 15 / 14 | 100% / 100% |  |
| 834 | Drednaw | converted | 15 / 15 | 100% / 100% |  |
| 835 | Yamper | converted | 14 / 12 | 100% / 100% |  |
| 836 | Boltund | converted | 15 / 12 | 100% / 100% |  |
| 837 | Rolycoly | converted | 13 / 8 | 100% / 100% |  |
| 838 | Carkol | converted | 13 / 10 | 100% / 100% |  |
| 839 | Coalossal | converted | 15 / 11 | 100% / 100% | front scaled to 96% |
| 840 | Applin | converted | 13 / 13 | 100% / 100% |  |
| 841 | Flapple | converted | 15 / 14 | 100% / 100% |  |
| 842 | Appletun | converted | 14 / 13 | 100% / 100% |  |
| 843 | Silicobra | converted | 12 / 10 | 100% / 100% |  |
| 844 | Sandaconda | converted | 12 / 9 | 100% / 100% | front scaled to 94% |
| 845 | Cramorant | converted | 14 / 12 | 100% / 100% |  |
| 846 | Arrokuda | converted | 14 / 14 | 100% / 100% |  |
| 847 | Barraskewda | converted | 13 / 12 | 100% / 100% | front scaled to 95%; back scaled to 95% |
| 848 | Toxel | converted | 14 / 10 | 100% / 100% |  |
| 849 | Toxtricity | converted | 12 / 12 | 100% / 100% | front scaled to 95% |
| 850 | Sizzlipede | converted | 13 / 11 | 100% / 100% |  |
| 851 | Centiskorch | converted | 14 / 12 | 100% / 100% | front scaled to 91% |
| 852 | Clobbopus | converted | 12 / 8 | 100% / 100% |  |
| 853 | Grapploct | converted | 14 / 12 | 100% / 100% |  |
| 854 | Sinistea | converted | 14 / 11 | 100% / 100% |  |
| 855 | Polteageist | converted | 15 / 13 | 100% / 100% |  |
| 856 | Hatenna | converted | 9 / 9 | 100% / 100% |  |
| 857 | Hattrem | converted | 14 / 11 | 100% / 100% |  |
| 858 | Hatterene | converted | 14 / 6 | 100% / 100% |  |
| 859 | Impidimp | converted | 12 / 8 | 100% / 100% |  |
| 860 | Morgrem | converted | 14 / 11 | 100% / 100% |  |
| 861 | Grimmsnarl | converted | 14 / 8 | 100% / 100% | front scaled to 96% |
| 862 | Obstagoon | converted | 13 / 13 | 100% / 100% |  |
| 863 | Perrserker | converted | 14 / 10 | 100% / 100% |  |
| 864 | Cursola | converted | 14 / 9 | 100% / 100% | front scaled to 92%; back scaled to 93% |
| 865 | Sirfetch’d | converted | 14 / 13 | 100% / 100% | front scaled to 85%; back scaled to 86% |
| 866 | Mr. Rime | converted | 15 / 9 | 100% / 100% |  |
| 867 | Runerigus | converted | 9 / 6 | 100% / 100% | front scaled to 86%; back scaled to 90% |
| 868 | Milcery | converted | 7 / 5 | 100% / 100% |  |
| 869 | Alcremie | converted | 11 / 10 | 100% / 100% |  |
| 870 | Falinks | converted | 12 / 11 | 100% / 100% | front scaled to 99% |
| 871 | Pincurchin | converted | 11 / 11 | 100% / 100% |  |
| 872 | Snom | converted | 9 / 8 | 100% / 100% |  |
| 873 | Frosmoth | converted | 13 / 6 | 100% / 100% |  |
| 874 | Stonjourner | converted | 13 / 11 | 100% / 100% |  |
| 875 | Eiscue | converted | 14 / 9 | 100% / 100% | front scaled to 98% |
| 876 | Indeedee | converted | 13 / 10 | 100% / 100% |  |
| 877 | Morpeko | converted | 15 / 10 | 100% / 100% |  |
| 878 | Cufant | converted | 14 / 12 | 100% / 100% |  |
| 879 | Copperajah | converted | 14 / 13 | 100% / 100% |  |
| 880 | Dracozolt | converted | 15 / 12 | 100% / 100% | back scaled to 89% |
| 881 | Arctozolt | converted | 14 / 13 | 100% / 100% | front scaled to 99% |
| 882 | Dracovish | converted | 14 / 13 | 100% / 100% | front scaled to 98% |
| 883 | Arctovish | converted | 13 / 12 | 100% / 100% |  |
| 884 | Duraludon | converted | 14 / 13 | 100% / 100% |  |
| 885 | Dreepy | converted | 13 / 11 | 100% / 100% |  |
| 886 | Drakloak | converted | 15 / 10 | 100% / 100% |  |
| 887 | Dragapult | converted | 15 / 13 | 100% / 100% |  |
| 888 | Zacian | converted | 12 / 13 | 100% / 100% | front scaled to 98% |
| 889 | Zamazenta | converted | 12 / 12 | 100% / 100% | front scaled to 89% |
| 890 | Eternatus | converted | 15 / 8 | 100% / 100% | front scaled to 89% |
| 891 | Kubfu | converted | 13 / 9 | 100% / 100% |  |
| 892 | Urshifu | converted | 13 / 13 | 100% / 100% | front scaled to 98% |
| 893 | Zarude | converted | 15 / 8 | 100% / 100% | front scaled to 92% |
| 894 | Regieleki | converted | 11 / 10 | 100% / 100% | front scaled to 86%; back scaled to 86% |
| 895 | Regidrago | converted | 14 / 11 | 100% / 100% |  |
| 896 | Glastrier | converted | 8 / 9 | 100% / 100% | front scaled to 96%; back scaled to 98% |
| 897 | Spectrier | converted | 11 / 11 | 100% / 100% | back scaled to 98% |
| 898 | Calyrex | converted | 13 / 13 | 100% / 100% | front scaled to 94% |
| 899 | Wyrdeer | converted | 15 / 12 | 100% / 100% | front scaled to 88% |
| 900 | Kleavor | converted | 12 / 11 | 100% / 100% |  |
| 901 | Ursaluna | converted | 15 / 9 | 100% / 100% |  |
| 902 | Basculegion | converted | 14 / 12 | 100% / 100% | front scaled to 93% |
| 903 | Sneasler | converted | 15 / 13 | 100% / 99% |  |
| 904 | Overqwil | converted | 15 / 13 | 100% / 100% | front scaled to 86% |
| 905 | Enamorus | converted | 15 / 12 | 100% / 100% | front scaled to 98% |
| 906 | Sprigatito | converted | 11 / 10 | 100% / 100% |  |
| 907 | Floragato | converted | 12 / 10 | 100% / 100% |  |
| 908 | Meowscarada | converted | 12 / 9 | 100% / 100% |  |
| 909 | Fuecoco | converted | 15 / 9 | 99% / 100% |  |
| 910 | Crocalor | converted | 13 / 13 | 100% / 100% |  |
| 911 | Skeledirge | converted | 15 / 14 | 100% / 100% | front scaled to 98% |
| 912 | Quaxly | converted | 13 / 11 | 100% / 100% |  |
| 913 | Quaxwell | converted | 15 / 15 | 100% / 97% |  |
| 914 | Quaquaval | converted | 15 / 15 | 100% / 100% |  |
| 915 | Lechonk | converted | 13 / 14 | 100% / 100% |  |
| 916 | Oinkologne | converted | 13 / 11 | 100% / 100% |  |
| 917 | Tarountula | converted | 14 / 12 | 100% / 100% |  |
| 918 | Spidops | converted | 15 / 10 | 100% / 100% |  |
| 919 | Nymble | converted | 10 / 10 | 99% / 100% |  |
| 920 | Lokix | converted | 13 / 13 | 100% / 100% |  |
| 921 | Pawmi | converted | 14 / 10 | 100% / 100% |  |
| 922 | Pawmo | converted | 13 / 9 | 100% / 100% |  |
| 923 | Pawmot | converted | 12 / 7 | 100% / 100% |  |
| 924 | Tandemaus | converted | 8 / 8 | 100% / 100% |  |
| 925 | Maushold | converted | 8 / 8 | 100% / 100% |  |
| 926 | Fidough | converted | 11 / 9 | 100% / 100% |  |
| 927 | Dachsbun | converted | 13 / 11 | 100% / 100% |  |
| 928 | Smoliv | converted | 13 / 11 | 48% / 100% | shiny front doesn't line up (19% of pixels) |
| 929 | Dolliv | converted | 13 / 11 | 100% / 100% |  |
| 930 | Arboliva | converted | 15 / 8 | 100% / 100% | front scaled to 96% |
| 931 | Squawkabilly | converted | 15 / 13 | 100% / 100% |  |
| 932 | Nacli | converted | 14 / 10 | 100% / 100% |  |
| 933 | Naclstack | converted | 13 / 14 | 100% / 100% |  |
| 934 | Garganacl | converted | 13 / 6 | 100% / 100% | front scaled to 91% |
| 935 | Charcadet | converted | 15 / 15 | 100% / 100% |  |
| 936 | Armarouge | converted | 15 / 11 | 100% / 100% | front scaled to 99% |
| 937 | Ceruledge | converted | 15 / 13 | 100% / 100% | front scaled to 96% |
| 938 | Tadbulb | converted | 12 / 10 | 100% / 100% |  |
| 939 | Bellibolt | converted | 15 / 9 | 100% / 100% |  |
| 940 | Wattrel | converted | 15 / 13 | 100% / 100% |  |
| 941 | Kilowattrel | converted | 14 / 12 | 100% / 100% |  |
| 942 | Maschiff | converted | 14 / 10 | 100% / 100% |  |
| 943 | Mabosstiff | converted | 13 / 13 | 100% / 100% |  |
| 944 | Shroodle | converted | 16 / 10 | 98% / 100% |  |
| 945 | Grafaiai | converted | 15 / 9 | 100% / 100% |  |
| 946 | Bramblin | converted | 11 / 14 | 100% / 100% |  |
| 947 | Brambleghast | converted | 13 / 14 | 100% / 100% |  |
| 948 | Toedscool | converted | 12 / 9 | 100% / 100% |  |
| 949 | Toedscruel | converted | 14 / 12 | 32% / 100% | shiny front doesn't line up (63% of pixels) |
| 950 | Klawf | converted | 15 / 10 | 100% / 100% |  |
| 951 | Capsakid | converted | 13 / 11 | 100% / 100% |  |
| 952 | Scovillain | converted | 15 / 10 | 100% / 100% |  |
| 953 | Rellor | converted | 15 / 12 | 100% / 100% |  |
| 954 | Rabsca | converted | 14 / 14 | 100% / 100% |  |
| 955 | Flittle | converted | 15 / 12 | 100% / 100% |  |
| 956 | Espathra | converted | 15 / 12 | 100% / 100% |  |
| 957 | Tinkatink | converted | 15 / 12 | 100% / 100% |  |
| 958 | Tinkatuff | converted | 15 / 14 | 100% / 100% |  |
| 959 | Tinkaton | converted | 14 / 12 | 100% / 100% |  |
| 960 | Wiglett | converted | 12 / 9 | 100% / 100% |  |
| 961 | Wugtrio | converted | 14 / 10 | 100% / 100% |  |
| 962 | Bombirdier | converted | 14 / 11 | 100% / 100% |  |
| 963 | Finizen | converted | 14 / 9 | 100% / 100% |  |
| 964 | Palafin | converted | 15 / 10 | 100% / 100% |  |
| 965 | Varoom | converted | 14 / 14 | 100% / 100% |  |
| 966 | Revavroom | converted | 14 / 10 | 100% / 100% |  |
| 967 | Cyclizar | converted | 15 / 13 | 100% / 100% |  |
| 968 | Orthworm | converted | 13 / 13 | 100% / 100% |  |
| 969 | Glimmet | converted | 14 / 11 | 100% / 100% |  |
| 970 | Glimmora | converted | 14 / 9 | 100% / 100% |  |
| 971 | Greavard | converted | 13 / 13 | 100% / 100% |  |
| 972 | Houndstone | converted | 13 / 12 | 100% / 100% |  |
| 973 | Flamigo | converted | 11 / 11 | 100% / 100% |  |
| 974 | Cetoddle | converted | 10 / 4 | 100% / 100% |  |
| 975 | Cetitan | converted | 12 / 10 | 100% / 100% | front scaled to 85% |
| 976 | Veluza | converted | 14 / 13 | 100% / 100% |  |
| 977 | Dondozo | converted | 14 / 9 | 100% / 100% | front scaled to 91% |
| 978 | Tatsugiri | converted | 13 / 11 | 100% / 100% |  |
| 979 | Annihilape | converted | 14 / 8 | 100% / 100% |  |
| 980 | Clodsire | converted | 8 / 8 | 100% / 100% |  |
| 981 | Farigiraf | converted | 15 / 13 | 100% / 100% | front scaled to 94% |
| 982 | Dudunsparce | converted | 14 / 12 | 100% / 100% |  |
| 983 | Kingambit | converted | 15 / 11 | 100% / 100% | front scaled to 88% |
| 984 | Great Tusk | converted | 15 / 12 | 100% / 100% | front scaled to 85% |
| 985 | Scream Tail | converted | 14 / 7 | 100% / 100% |  |
| 986 | Brute Bonnet | converted | 15 / 11 | 100% / 100% |  |
| 987 | Flutter Mane | converted | 14 / 14 | 100% / 100% |  |
| 988 | Slither Wing | converted | 15 / 14 | 100% / 100% | front scaled to 94% |
| 989 | Sandy Shocks | converted | 15 / 14 | 100% / 100% | front scaled to 99% |
| 990 | Iron Treads | converted | 13 / 11 | 100% / 100% |  |
| 991 | Iron Bundle | converted | 15 / 14 | 100% / 100% |  |
| 992 | Iron Hands | converted | 15 / 14 | 100% / 100% | front scaled to 90% |
| 993 | Iron Jugulis | converted | 15 / 6 | 100% / 100% | front scaled to 99% |
| 994 | Iron Moth | converted | 15 / 10 | 100% / 100% | front scaled to 87% |
| 995 | Iron Thorns | converted | 12 / 10 | 100% / 100% |  |
| 996 | Frigibax | converted | 14 / 12 | 100% / 100% |  |
| 997 | Arctibax | converted | 14 / 10 | 100% / 100% |  |
| 998 | Baxcalibur | converted | 12 / 9 | 100% / 100% |  |
| 999 | Gimmighoul | converted | 15 / 12 | 100% / 100% |  |
| 1000 | Gholdengo | converted | 14 / 9 | 100% / 100% | front scaled to 96% |
| 1001 | Wo-Chien | converted | 15 / 14 | 100% / 100% | front scaled to 90% |
| 1002 | Chien-Pao | converted | 15 / 13 | 100% / 100% | front scaled to 98% |
| 1003 | Ting-Lu | converted | 17 / 13 | 94% / 100% | shiny front moved (+1, +1) to line up; front scaled to 92% |
| 1004 | Chi-Yu | converted | 15 / 15 | 100% / 100% |  |
| 1005 | Roaring Moon | converted | 15 / 14 | 100% / 100% | front scaled to 83% |
| 1006 | Iron Valiant | converted | 15 / 14 | 100% / 100% | front scaled to 96% |
| 1007 | Koraidon | converted | 14 / 15 | 100% / 100% | front scaled to 85% |
| 1008 | Miraidon | converted | 15 / 12 | 100% / 100% | front scaled to 93% |
| 1009 | Walking Wake | converted | 15 / 14 | 100% / 100% | front scaled to 94% |
| 1010 | Iron Leaves | converted | 15 / 14 | 100% / 100% |  |
| 1011 | Dipplin | converted | 15 / 10 | 100% / 100% |  |
| 1012 | Poltchageist | converted | 15 / 13 | 100% / 100% |  |
| 1013 | Sinistcha | converted | 15 / 14 | 100% / 100% |  |
| 1014 | Okidogi | converted | 13 / 14 | 100% / 100% | front scaled to 91% |
| 1015 | Munkidori | converted | 11 / 14 | 100% / 100% |  |
| 1016 | Fezandipiti | converted | 14 / 14 | 100% / 100% |  |
| 1017 | Ogerpon | converted | 15 / 10 | 100% / 100% |  |
| 1018 | Archaludon | converted | 14 / 13 | 100% / 100% | front scaled to 91% |
| 1019 | Hydrapple | converted | 15 / 14 | 100% / 100% |  |
| 1020 | Gouging Fire | converted | 15 / 10 | 100% / 100% | front scaled to 95% |
| 1021 | Raging Bolt | converted | 15 / 14 | 100% / 100% | front scaled to 83% |
| 1022 | Iron Boulder | converted | 15 / 15 | 100% / 100% |  |
| 1023 | Iron Crown | converted | 16 / 14 | 99% / 100% | shiny front moved (+0, -2) to line up; front scaled to 96% |
| 1024 | Terapagos | converted | 15 / 14 | 100% / 100% |  |
| 1025 | Pecharunt | converted | 14 / 12 | 100% / 100% |  |
