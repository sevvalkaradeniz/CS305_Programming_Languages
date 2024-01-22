%{
#include <stdio.h>
void yyerror (const char *s) /* Called by yyparse on error */
{
    return;
}
%}
%token tMAIL tENDMAIL tSCHEDULE tENDSCHEDULE tSEND tSET tTO tFROM tAT tCOMMA tCOLON tLPR tRPR tLBR tRBR tIDENT tSTRING tADDRESS tDATE tTIME
%% /* Grammar rules and actions follow */

mainProgram: 
            |setStatement
            |mailBlock
            |mainProgram setStatement
            |mainProgram mailBlock
;

mailBlock: tMAIL tFROM tADDRESS tCOLON insideOfMailBlock tENDMAIL
        |tMAIL tFROM tADDRESS tCOLON  tENDMAIL
;

setStatement: tSET tIDENT tLPR tSTRING tRPR;

recepientObjects: tLPR tADDRESS tRPR
                  |tLPR tIDENT tCOMMA tADDRESS tRPR
                  |tLPR tSTRING tCOMMA tADDRESS tRPR
;
recepientList: recepientObjects
                |recepientList tCOMMA recepientObjects
;
sendStatement: tSEND tLBR tIDENT tRBR tTO tLBR recepientList tRBR    
                |tSEND tLBR tSTRING tRBR tTO tLBR recepientList tRBR
;

scheduleStatement:  sendStatement 
                    |scheduleStatement sendStatement 
;
scheduleStatementFinal: tSCHEDULE tAT tLBR tDATE tCOMMA tTIME tRBR tCOLON scheduleStatement tENDSCHEDULE;

insideOfMailBlock: setStatement
                    |scheduleStatementFinal
                    |sendStatement
                    |insideOfMailBlock setStatement
                    |insideOfMailBlock scheduleStatementFinal
                    |insideOfMailBlock sendStatement
                    
;





%%
int main ()
{
    if (yyparse())
    {
        // parse error
        printf("ERROR\n");
        return 1;
    }
    else
    {
        // successful parsing
        printf("OK\n");
        return 0;
    }
}