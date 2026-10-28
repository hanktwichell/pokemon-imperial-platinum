#!/usr/bin/env python3

import argparse
import os
import pathlib
import shutil
import subprocess

SPECIES_DIRS = os.environ['SPECIES'].split(';')

argparser = argparse.ArgumentParser(
    prog='pl_poke_icon.narc packer',
    description='Packs the archive containing Pokemon icons'
)
argparser.add_argument('-n', '--nitrogfx',
                       required=True,
                       help='Path to nitrogfx executable')
argparser.add_argument('-k', '--narc',
                       required=True,
                       help='Path to narc executable')
argparser.add_argument('-s', '--source-dir',
                       required=True,
                       help='Path to the source directory (res/pokemon)')
argparser.add_argument('-p', '--private-dir',
                       required=True,
                       help='Path to the private directory (where binaries will be made)')
argparser.add_argument('-o', '--output-dir',
                       required=True,
                       help='Path to the output directory (where the NARC will be made)')
args = argparser.parse_args()

source_dir = pathlib.Path(args.source_dir)
private_dir = pathlib.Path(args.private_dir)
output_dir = pathlib.Path(args.output_dir)

private_dir.mkdir(parents=True, exist_ok=True)

for i, subdir in enumerate(SPECIES_DIRS):
    # Do not attempt to process either egg or bad_egg
    if subdir in ['egg', 'bad_egg']:
        continue

    j = 0
    for face in ['back', 'front']:
        for gender in ['female', 'male']:
            source_file = source_dir / subdir / f'{gender}_{face}.png'
            target_file = private_dir / f'{i:04}-{j:02}.NCGR'

            if source_file.exists():
                subprocess.run([
                    args.nitrogfx,
                    source_file,
                    target_file,
                    '-encodefronttoback',
                    '-scan',
                ])
            else:
                subprocess.run(['touch', target_file])

            j += 1

    if i == 0:  # species none has special palette files
        shutil.copy(source_dir / 'none/normal_pal.NCLR', private_dir / '0000-04.NCLR')
        shutil.copy(source_dir / 'none/shiny_pal.NCLR', private_dir / '0000-05.NCLR')
        continue

    normal_pal_src = source_dir / subdir / 'normal.pal'
    shiny_pal_src = source_dir / subdir / 'shiny.pal'

    subprocess.run([
        args.nitrogfx,
        normal_pal_src,
        private_dir / f'{i:04}-04.NCLR',
        '-bitdepth', '8',
        '-nopad',
        '-comp', '10'
    ])
    subprocess.run([
        args.nitrogfx,
        shiny_pal_src,
        private_dir / f'{i:04}-05.NCLR',
        '-bitdepth', '8',
        '-nopad',
        '-comp', '10'
    ])

# Sovereign: two back palettes (normal, shiny) for each species, after all the species' six files. The archive packs
# files in name order, so the "zback" names sort last; BuildPokemonSpriteTemplate (src/pokemon.c) reads them at
# POKEGRA_BACK_PALETTE_BASE + species * 2 + shiny. A species without back_normal.pal/back_shiny.pal uses its front
# palettes for its back, as in Platinum.
for i, subdir in enumerate(SPECIES_DIRS):
    if subdir in ['egg', 'bad_egg']:
        continue

    for shiny, name in enumerate(['normal', 'shiny']):
        target = private_dir / f'zback-{i:04}-{shiny}.NCLR'
        if i == 0:
            shutil.copy(source_dir / f'none/{name}_pal.NCLR', target)
            continue

        back_src = source_dir / subdir / f'back_{name}.pal'
        if not back_src.exists():
            back_src = source_dir / subdir / f'{name}.pal'
        subprocess.run([
            args.nitrogfx,
            back_src,
            target,
            '-bitdepth', '8',
            '-nopad',
            '-comp', '10'
        ])

# Sovereign: then three files (front image, normal and shiny palette) for each Mega and Primal form with a front of
# its own, in sovereign_form_sprites/order.txt's order (tools/sprites/convert_form_sprites.py); "zform" sorts after
# "zback". BuildPokemonSpriteTemplate reads them at POKEGRA_FORM_SPRITE_BASE + sprite * 3.
form_dir = source_dir / 'sovereign_form_sprites'
for k, folder in enumerate((form_dir / 'order.txt').read_text().splitlines()):
    subprocess.run([
        args.nitrogfx,
        form_dir / folder / 'front.png',
        private_dir / f'zform-{k:03}-0.NCGR',
        '-encodefronttoback',
        '-scan',
    ])
    for n, name in enumerate(['normal', 'shiny'], start=1):
        subprocess.run([
            args.nitrogfx,
            form_dir / folder / f'{name}.pal',
            private_dir / f'zform-{k:03}-{n}.NCLR',
            '-bitdepth', '8',
            '-nopad',
            '-comp', '10'
        ])

# Sovereign: then three files (back image, normal and shiny palette) for each Mega and Primal form with a back of its
# own, in sovereign_form_backs/order.txt's order (tools/sprites/convert_form_backs.py); "zformback" sorts after
# "zform-". BuildPokemonSpriteTemplate reads them at POKEGRA_FORM_BACK_BASE + back * 3.
back_dir = source_dir / 'sovereign_form_backs'
for k, folder in enumerate((back_dir / 'order.txt').read_text().splitlines()):
    subprocess.run([
        args.nitrogfx,
        back_dir / folder / 'back.png',
        private_dir / f'zformback-{k:03}-0.NCGR',
        '-encodefronttoback',
        '-scan',
    ])
    for n, name in enumerate(['normal', 'shiny'], start=1):
        subprocess.run([
            args.nitrogfx,
            back_dir / folder / f'{name}.pal',
            private_dir / f'zformback-{k:03}-{n}.NCLR',
            '-bitdepth', '8',
            '-nopad',
            '-comp', '10'
        ])

subprocess.run([
    args.narc,
    '--create',
    '--file', output_dir / 'pl_pokegra.narc',
    private_dir
])
