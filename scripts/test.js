
nowTime = 11
limitTime = 12

ticketSold = 11
soldTicketLimit = 11

totalSupply = 15

if ((ticketSold == totalSupply) || ((ticketSold >= soldTicketLimit) && (nowTime >= limitTime))) {
    console.log('True')
}  
else {
    console.log('False')
}
            