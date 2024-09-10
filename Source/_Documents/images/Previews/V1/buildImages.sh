#!/bin/bash

clear

#brew install imagemagick

echo 'Building New Images...'

magick montage t1.dark.png t2.dark.png t3.dark.png t4.dark.png -tile 4x1 -geometry +0+0 generated/4x1_dark_0.png
magick montage t1.light.png t2.light.png t3.light.png t4.light.png -tile 4x1 -geometry +0+0 generated/4x1_light_0.png

magick montage t1.dark.png t2.dark.png t3.dark.png t4.dark.png -tile 4x1 -geometry +1+0 generated/4x1_dark_1.png
magick montage t1.light.png t2.light.png t3.light.png t4.light.png -tile 4x1 -geometry +1+0 generated/4x1_light_1.png

magick montage t1.dark.png t2.dark.png t3.dark.png t4.dark.png -tile 4x1 -geometry +5+0 generated/4x1_dark_5.png
magick montage t1.light.png t2.light.png t3.light.png t4.light.png -tile 4x1 -geometry +5+0 generated/4x1_light_5.png

magick montage onboarding_1.png onboarding_2.png onboarding_3.png onboarding_4.png onboarding_5.png -tile 5x1 -geometry +0+0 generated/5x1_onboarding_0.png
magick montage onboarding_1.png onboarding_2.png onboarding_3.png onboarding_4.png onboarding_5.png -tile 5x1 -geometry +1+0 generated/5x1_onboarding_1.png
magick montage onboarding_1.png onboarding_2.png onboarding_3.png onboarding_4.png onboarding_5.png -tile 5x1 -geometry +5+0 generated/5x1_onboarding_5.png

echo 'Building JPGs...'

magick convert t1.dark.png generated/t1.dark.jpg
magick convert t2.dark.png generated/t2.dark.jpg
magick convert t3.dark.png generated/t3.dark.jpg
magick convert t4.dark.png generated/t4.dark.jpg

magick convert t1.light.png generated/t1.light.jpg
magick convert t2.light.png generated/t2.light.jpg
magick convert t3.light.png generated/t3.light.jpg
magick convert t4.light.png generated/t4.light.jpg

#magick convert 4x1_dark_0.png generated/4x1_dark_0.jpg
#magick convert 4x1_light_0.png generated/4x1_light_0.jpg

#magick convert 4x1_dark_1.png generated/4x1_dark_1.jpg
#magick convert 4x1_light_1.png generated/4x1_light_1.jpg

#magick convert 4x1_dark_5.png generated(/x1_dark_5.jpg
#magick convert 4x1_light_5.png generated/4x1_light_5.jpg

#magick convert 5x1_onboarding_0.png 5x1_onboarding_0.jpg
#magick convert 5x1_onboarding_1.png 5x1_onboarding_1.jpg
#magick convert 5x1_onboarding_5.png 5x1_onboarding_5.jpg

echo 'Done!'
