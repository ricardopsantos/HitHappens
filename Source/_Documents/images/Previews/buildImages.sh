#!/bin/bash

clear

#brew install imagemagick

echo 'Building New Images...'


magick montage t1.15pro.max.dark.png t2.15pro.max.dark.png t3.15pro.max.dark.png t4.15pro.max.dark.png -tile 4x1 -geometry +5+0 generated/preview_15pro_dark.jpg
magick montage t1.15pro.max.light.png t2.15pro.max.light.png t3.15pro.max.light.png t4.15pro.max.light.png -tile 4x1 -geometry +5+0 generated/preview_15pro_light.jpg

magick montage t1.se.dark.png t2.se.dark.png t3.se.dark.png t4.se.dark.png -tile 4x1 -geometry +5+0 generated/preview_se_dark.jpg
magick montage t1.se.light.png t2.se.light.png t3.se.light.png t4.se.light.png -tile 4x1 -geometry +5+0 generated/preview_se_light.jpg

magick montage 1_onboarding_15pro.dark.png 2_onboarding_15pro.dark.png 3_onboarding_15pro.dark.png 4_onboarding_15pro.dark.png 5_onboarding_15pro.dark.png -tile 5x1 -geometry +5+0 generated/onboarding_15pro.dark.jpg
magick montage 1_onboarding_15pro.light.png 2_onboarding_15pro.light.png 3_onboarding_15pro.light.png 4_onboarding_15pro.light.png 5_onboarding_15pro.light.png -tile 5x1 -geometry +5+0 generated/onboarding_15pro.light.jpg

echo 'Building JPGs...'

magick t1.15pro.max.dark.png generated/t1.15pro.dark.jpg
magick t2.15pro.max.dark.png generated/t2.15pro.dark.jpg
magick t3.15pro.max.dark.png generated/t3.15pro.dark.jpg
magick t4.15pro.max.dark.png generated/t4.15pro.dark.jpg

magick t1.15pro.max.light.png generated/t1.15pro.light.jpg
magick t2.15pro.max.light.png generated/t2.15pro.light.jpg
magick t3.15pro.max.light.png generated/t3.15pro.light.jpg
magick t4.15pro.max.light.png generated/t4.15pro.light.jpg

magick t1.se.dark.png generated/t1.se.dark.jpg
magick t2.se.dark.png generated/t2.se.dark.jpg
magick t3.se.dark.png generated/t3.se.dark.jpg
magick t4.se.dark.png generated/t4.se.dark.jpg

magick t1.se.light.png generated/t1.se.light.jpg
magick t2.se.light.png generated/t2.se.light.jpg
magick t3.se.light.png generated/t3.se.light.jpg
magick t4.se.light.png generated/t4.se.light.jpg

#magick generated/onboarding_15pro.dark.png generated/onboarding_15pro.dark.jpg
#magick generated/onboarding_15pro.light.png generated/onboarding_15pro.light.jpg

echo 'Done!'
