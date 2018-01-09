#!bin/sh

name=
age=
level="amateur"
tourCorrectAnswer="false"
tourMistakes=
approvedBikers=
age="13"
tourFinished="False"

dialog --msgbox "1. Prerequisities
Please make sure you are familiar with the functional description of a bicycle:
							S1000DBIKE-AAA-D00-00-00-00AA-042A-A
						            

" 24 80
dialog --inputbox "Enter your name" 24 80 2>tmp
name=$(cat tmp)
rm tmp
valid=false
while ! $valid
do
dialog --inputbox "Enter your age" 24 80 2>tmp
age=$(cat tmp)
rm tmp
if [ $age -ge 4  ] && [  $age -le 100 ]
then
valid=true
else
dialog --title Error --msgbox "Age must be within 4 to 100" 24 80
fi
done
dialog --no-tags --radiolist "Did you ever ride a bicycle?" 24 80 24 "1" "Yes" off "2" "No" off  2>tmp
choice=$(cat tmp)
rm tmp
case $choice in
1) level="experienced"
;;
2) ;;
esac
if [ ! $level = "experienced" ]
then
tourMistakes=0

while [ "$tourFinished" = "False" ]
do
dialog --msgbox "1. Introduction
Dear $name, because you are an unexperienced user, you will be presented a brief introduction on how to operate a bicycle.

2. Click next.

" 24 80
dialog --msgbox "1. Did you really read the instructions?
Before you can proceed to the practical section of this manual, you will be given a simple question to test whether you read the instructions carefully.

" 24 80
dialog --no-tags --radiolist "The rear brake is operated by" 24 80 24 "1" "Left brake lever" off "2" "Right brake lever" off  2>tmp
choice=$(cat tmp)
rm tmp
case $choice in
1) tourCorrectAnswer="false"
tourMistakes=$(($tourMistakes + 1))
;;
2) tourCorrectAnswer="true"
tourFinished="true"
;;
esac
if [ "$tourCorrectAnswer" = "false" ]
then
dialog --msgbox "1. Wrong answer!
You will be given the introduction once again.

Number of mistakes: $tourMistakes
                                    

" 24 80
fi
if [ "$tourCorrectAnswer" = "true" ]
then
dialog --msgbox "1. Correct!
You can now continue with the practical part of this manual.

" 24 80
fi
done
fi
dialog --title "Practical part" --msgbox "1. Take the bicycle from the garage.

2. Clean the bicycle from the dust.

3. Sit on the bike.

4. ...and RIDE!

" 24 80
clear
