extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal evaluation_time_up
export var answer_time = 5

var machine = {
"0000": false,
"0001": false,
"0010": false,
"0011": true,
"0100": false,
"0101": true,
"0110": false,
"0111": true,
"1000": false,
"1001": false,
"1010": false,
"1011": false,
"1100": false,
"1101": true,
"1110": false,
"1111": true
}

var patients = {
  "Patients":
  [
    {"case": "#123", "id": "jdn232", "age": "58", "description": "Dizem os vizinhos que não conseguem dormir com o barulho que faz, especialmente desde que voltou de uma viagem misteriosa, de onde trouxe criaturas fantásticas\n", "pic": "", "key": "0011"},
    {"case": "#620", "id": "judm53", "age": "185", "description": "Chamam-lhe a corneta da noite. Corneta, porque com a temperatura que tem, não pode ser corneto. Não pode não\n", "pic": "", "key": "1011"},
    {"case": "#364", "id": "adg233", "age": "33", "description": "Tem em casa um lindo papagaio, que não se sabe de onde veio...\n", "pic": "", "key": "0100"},
    {"case": "#455", "id": "phn9k8", "age": "226", "description": "Foi viajar, e sente-se com imenso frio, apesar do calor que faz. A mulher dorme no quarto ao lado, com tampões nos