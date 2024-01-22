%{

#ifdef YYDEBUG
  yydebug = 1;
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "sevvalk-hw3.h"

void addSetStatementToLinkedList(SetStatementNode * newSetStatement);
void updateSetStatementIfGlobal(SetStatementNode * newSetStatement);
SendStatementNode * addSendStatementToLinkedList(SendStatementNode * newSetStatement);
ScheduleStatementNode * addScheduleStatementToLinkedList(ScheduleStatementNode * scheduleStatement);
MailBlockAllNode * addMailBlockToLinkedList(MailBlockAllNode * mailBlockAll);
void addScheduleStatementToListToSort(ScheduleStatementNode * scheduleStatement);
void addErrorMessageToTheLinkedList(errorMessagesNode *);

void sortScheduleList();
void sortErrorList();

int deleteSetStatementAfterMailBlockFinished();

SetStatementNode * makeSetStatementFromIdent(IdentifierNode, StringNode);
RecipientNode * makeRecipientNodeFromIdent(IdentifierNode, MailNode);
RecipientNode * makeRecipientNodeFromString(StringNode, MailNode );
RecipientNode * makeRecipientNodeFromMail(MailNode);

RecipientNode * updateHead(RecipientNode*);
SendStatementNode* updateHeadS(SendStatementNode*);
RecipientNode * updateRecipientListHead();
SendStatementNode * updateSendStatementListHead();
ScheduleStatementNode * updateScheduleStatementHeadInsideOfMailBlock();
SendStatementNode * updateSendStatementListHeadInsideOfMailBlock();
SetStatementNode * updateSetStatementListHead();

SendStatementNode * createSendStatementWithMessageWithString(StringNode stringVar);
ScheduleStatementNode * createScheduleStatement(DateNode, TimeNode);
MailBlockAllNode * createMailBlockForSendAndSchedule(MailNode mail);
SendStatementNode * createSendStatementWithMessageWithIdent(IdentifierNode identNew);

void printSendStatements(SendStatementNode * , MailNode);
void printScheduleStatements();
void printStatements();
void printErrors();

int checkIdentifier (char*);
char* findStringValueOfIdent(char* ptr);
void checkStatements(MailBlockAllNode * currBlock);

void checkDate(DateNode);
void checkTime(TimeNode);
void checkStatements();
void printEMailNotification();
void printRecipients();

SetStatementNode ** setStatements;
SendStatementNode ** sendStatements;
ScheduleStatementNode ** scheduleStatements;


RecipientNode * head=NULL;
SendStatementNode * headS = NULL;
SendStatementNode * headToAllSendStatements=NULL;
ScheduleStatementNode * headToAllScheduleStatements=NULL;
ScheduleStatementNode * headToSortedScheduleStatements=NULL;
MailBlockAllNode * headOfMailBlocks=NULL;
SetStatementNode * headToSetStatements=NULL;
SetStatementNode * headToGlobalSetStatements=NULL;
errorMessagesNode * headToErrorMessages=NULL;


char MonthStringValues[][12]={"","January","February","March","April",
"May","June","July","August","September","October","November","December"};

int flagForError=0;


void yyerror (const char *s) /* Called by yyparse on error */
{
    return;
}
%}

%union{
  IdentifierNode identifierNode;
  StringNode stringNode;
  MailNode mailNode;

  RecipientNode * RecipientNodePtr;
  SetStatementNode * setStatementNodePtr;

  SendStatementNode * sendStatementNodePtr;

  ScheduleStatementNode * scheduleStatementNodePtr;

  MailBlockAllNode * MailBlockAllNodePtr;

  DateNode dateNode;
  TimeNode timeNode;

  
}
%token tMAIL tENDMAIL tSCHEDULE tENDSCHEDULE tSEND tTO tFROM tSET tCOMMA tCOLON tLPR tRPR tLBR tRBR tAT 

%token <timeNode> tTIME;
%token <dateNode> tDATE 
%token <stringNode> tSTRING
%token <identifierNode> tIDENT
%token <mailNode> tADDRESS

%type <setStatementNodePtr> setStatement
%type <RecipientNodePtr> recipient
%type <RecipientNodePtr> recipientList
%type <sendStatementNodePtr> sendStatement
%type <sendStatementNodePtr> sendStatements
%type <scheduleStatementNodePtr> scheduleStatement
%type <MailBlockAllNodePtr> mailBlock

%start program

%%

program : statements{
}
;

statements: 
            |  statements setStatement{
              updateSetStatementIfGlobal($2);
            }
            |  statements mailBlock{
              //printf("MAIL\n");
              addMailBlockToLinkedList($2);
            }
;

mailBlock : tMAIL tFROM tADDRESS tCOLON statementList tENDMAIL{
  $$= createMailBlockForSendAndSchedule($3);
  
}
;

statementList: 
                |  statementList setStatement{
                  addSetStatementToLinkedList($2);
                }
                |  statementList sendStatement{              
                  addSendStatementToLinkedList($2);
                  
                }
                |  statementList scheduleStatement{
                  addScheduleStatementToLinkedList($2);
                }
;

sendStatements: sendStatement{
   updateHeadS($1);
  $$ =($1);
}
                |  sendStatements sendStatement {
                  updateHeadS($2);
                }
;

sendStatement : tSEND tLBR tIDENT tRBR tTO tLBR recipientList tRBR{
              $$=createSendStatementWithMessageWithIdent($3);
            
            
}
                |tSEND tLBR tSTRING tRBR tTO tLBR recipientList tRBR{
                   $$ = createSendStatementWithMessageWithString($3);                  
                }

;


recipientList : recipient{
  $$ =($1);
}
            | recipientList tCOMMA recipient
            
;

recipient : tLPR tADDRESS tRPR{
  $$ = makeRecipientNodeFromMail($2);
}
            | tLPR tSTRING tCOMMA tADDRESS tRPR
            {
              $$ = makeRecipientNodeFromString($2,$4);
            }
            | tLPR tIDENT tCOMMA tADDRESS tRPR{
                $$ = makeRecipientNodeFromIdent($2,$4);
              
            }
;

scheduleStatement : tSCHEDULE tAT tLBR tDATE tCOMMA tTIME tRBR tCOLON sendStatements tENDSCHEDULE
{
  checkTime($6);
  checkDate($4);
  $$ = createScheduleStatement($4,$6);
}
;

setStatement : tSET tIDENT tLPR tSTRING tRPR{
  //printf("INDET: %s \n", $2.variableName);
  $$ = makeSetStatementFromIdent($2,$4);
}
;

%%

void printSendStatements(SendStatementNode * sendStatements, MailNode currentMail){
  while(sendStatements!=NULL){
    struct RecipientNode *p = sendStatements->head;
    while(p != NULL) {
        printf("E-mail sent from %s to ", currentMail.email);
        if(p->stringValue!=""){
          printf("%s: ",p->stringValue);         
        }
        else{
          printf("%s: ",p->email);
        }
        printf("\"%s\"\n", sendStatements->message);
        p = p->next;
       }
      sendStatements= sendStatements->next;
 
  }
}

void printScheduleStatements(){
  //printf("FUNCTION: printScheduleStatements\n");
  int i=0;
  ScheduleStatementNode * headSch = headOfMailBlocks->headOfSchedule;
  while(headToSortedScheduleStatements!=NULL){
    struct SendStatementNode *p = headToSortedScheduleStatements->head;   
       while(p != NULL) {
          struct RecipientNode * recit = p->head;      
        while(recit!=NULL){
          int monthOfTheDate= headToSortedScheduleStatements->date.month;
          printf("E-mail scheduled to be sent from %s ", headToSortedScheduleStatements->messageOfMail);
          printf("on %s %d, %d, %s to ", MonthStringValues[monthOfTheDate],headToSortedScheduleStatements->date.day, headToSortedScheduleStatements->date.year, headToSortedScheduleStatements->time.originalTime );
          if(recit->stringValue!=""){
          printf("%s: ",recit->stringValue);         
          }
          else{
            printf("%s: ",recit->email);
          }
          recit= recit->next;
          printf("\"%s\"\n",p->message);
        }
        p = p->next;
       }
       headToSortedScheduleStatements= headToSortedScheduleStatements->next;
       
  }
}

void printStatements(){
   //printf("FUNCTION: printStatements\n");
  MailBlockAllNode * tempHead = headOfMailBlocks;
  if(tempHead!=NULL){
      while(tempHead!=NULL){
    SendStatementNode * sendStatements = tempHead->headOfSend;
    printSendStatements(sendStatements,tempHead->mail);
    tempHead = tempHead->next;
    }
    tempHead=headOfMailBlocks;
    while(tempHead!=NULL && tempHead->next!=NULL){ 
      ScheduleStatementNode * scheduleStatements = tempHead->headOfSchedule;
            while( scheduleStatements!=NULL && scheduleStatements->next!=NULL){
                scheduleStatements->messageOfMail=tempHead->mail;
                //addScheduleStatementToListToSort(scheduleStatements);
                scheduleStatements=scheduleStatements->next;
            }  
              if(scheduleStatements!=NULL){
                scheduleStatements->messageOfMail=tempHead->mail;            
                tempHead= tempHead->next; 
                while( tempHead->next!=NULL && tempHead->headOfSchedule==NULL){
                  tempHead=tempHead->next;
                }  
                scheduleStatements->next= tempHead->headOfSchedule;                      
              }  
              else{
                tempHead= tempHead->next; 
              }        
              
    }
    ScheduleStatementNode * scheduleStatements = tempHead->headOfSchedule;
      while(scheduleStatements!=NULL){
        scheduleStatements->messageOfMail=tempHead->mail;
        scheduleStatements=scheduleStatements->next;
      }
    sortScheduleList();
    printScheduleStatements();
  }

}

void sortScheduleList(){
  //printf("FUNCTION: sortScheduleList\n");
  MailBlockAllNode * tempHead = headOfMailBlocks;
 while( tempHead->next!=NULL && tempHead->headOfSchedule==NULL){
        tempHead=tempHead->next;
  } 
  ScheduleStatementNode * currentScheduleStatements = tempHead->headOfSchedule;
  ScheduleStatementNode * sortedSendStatements=NULL;

  while(currentScheduleStatements!=NULL){
    ScheduleStatementNode * nextSch = currentScheduleStatements->next;
    if (sortedSendStatements == NULL || currentScheduleStatements->date.year < sortedSendStatements->date.year ||
            (currentScheduleStatements->date.year == sortedSendStatements->date.year && currentScheduleStatements->date.month < sortedSendStatements->date.month) ||
            (currentScheduleStatements->date.year == sortedSendStatements->date.year && currentScheduleStatements->date.month == sortedSendStatements->date.month && currentScheduleStatements->date.day < sortedSendStatements->date.day) ||
            (currentScheduleStatements->date.year == sortedSendStatements->date.year && currentScheduleStatements->date.month == sortedSendStatements->date.month && currentScheduleStatements->date.day == sortedSendStatements->date.day && currentScheduleStatements->time.hour < sortedSendStatements->time.hour) ||
             (currentScheduleStatements->date.year == sortedSendStatements->date.year && currentScheduleStatements->date.month == sortedSendStatements->date.month && currentScheduleStatements->date.day == sortedSendStatements->date.day && currentScheduleStatements->time.hour == sortedSendStatements->time.hour && currentScheduleStatements->time.minute < sortedSendStatements->time.minute)) {
            currentScheduleStatements->next = sortedSendStatements;
            sortedSendStatements = currentScheduleStatements;
        }

    else {
            
            struct ScheduleStatementNode* sortedCurrent = sortedSendStatements;
            while (sortedCurrent->next != NULL &&
                   (currentScheduleStatements->date.year > sortedCurrent->next->date.year ||
                    (currentScheduleStatements->date.year == sortedCurrent->next->date.year && currentScheduleStatements->date.month > sortedCurrent->next->date.month) ||
                    (currentScheduleStatements->date.year == sortedCurrent->next->date.year && currentScheduleStatements->date.month == sortedCurrent->next->date.month && currentScheduleStatements->date.day > sortedCurrent->next->date.day) ||
                     (currentScheduleStatements->date.year == sortedCurrent->next->date.year && currentScheduleStatements->date.month == sortedCurrent->next->date.month && currentScheduleStatements->date.day == sortedCurrent->next->date.day && currentScheduleStatements->time.hour > sortedCurrent->next->time.hour ) ||
                     (currentScheduleStatements->date.year == sortedCurrent->next->date.year && currentScheduleStatements->date.month == sortedCurrent->next->date.month && currentScheduleStatements->date.day == sortedCurrent->next->date.day && currentScheduleStatements->time.hour == sortedCurrent->next->time.hour && currentScheduleStatements->time.minute > sortedCurrent->next->time.minute))) {
                sortedCurrent = sortedCurrent->next;
            }
            currentScheduleStatements->next = sortedCurrent->next;
            sortedCurrent->next = currentScheduleStatements;
     }

     currentScheduleStatements = nextSch;
      
  }

   headToSortedScheduleStatements = sortedSendStatements;
   //printf("END OF FUNCTION: sortScheduleList\n");
}

void sortErrorList(){
  //printf("FUNCTION: sortErrorList\n");
  errorMessagesNode * errorHead = headToErrorMessages;
  errorMessagesNode * currentErrorMessages = errorHead;
  errorMessagesNode * sortedErrorMessages=NULL;
    while(currentErrorMessages!=NULL){
    errorMessagesNode * nextSch = currentErrorMessages->next;
    if (sortedErrorMessages == NULL || currentErrorMessages->lineNum < sortedErrorMessages->lineNum) {
            currentErrorMessages->next = sortedErrorMessages;
            sortedErrorMessages = currentErrorMessages;
        }

    else {
            struct errorMessagesNode* sortedCurrent = sortedErrorMessages;
            while (sortedCurrent->next != NULL && (currentErrorMessages->lineNum > sortedCurrent->lineNum )) {
                sortedCurrent = sortedCurrent->next;
            }
            currentErrorMessages->next = sortedCurrent->next;
            sortedCurrent->next = currentErrorMessages;
     }

     currentErrorMessages = nextSch;
      
  }
   headToErrorMessages = sortedErrorMessages;
}

void printErrors(){
  //printf("FUNCTION: printErrors\n");
  sortErrorList();
  while(headToErrorMessages!=NULL){
    if(headToErrorMessages->isDate){
       printf("ERROR at line %d: date object is not correct (%s)\n",headToErrorMessages->lineNum,headToErrorMessages->errMsg); 
    }
    if(headToErrorMessages->isTime){
     
      printf("ERROR at line %d: time object is not correct (%s)\n",headToErrorMessages->lineNum,headToErrorMessages->errMsg);    
    }
    if(headToErrorMessages->isSet){
      printf("ERROR at line %d: %s is undefined\n",headToErrorMessages->lineNum,headToErrorMessages->errMsg);
    }
    headToErrorMessages=headToErrorMessages->next;
  }
}

SetStatementNode * makeSetStatementFromIdent(IdentifierNode ident, StringNode stringVar){
   //printf("FUNCTION: makeSetStatementFromIdent\n");
      SetStatementNode * newNode = (SetStatementNode *)malloc(sizeof(SetStatementNode));
      newNode->identifier = ident.variableName;
      newNode->stringValue = stringVar.value;
      newNode->lineNum = ident.lineNum;
      //newNode->isGlobal=0;
      newNode->next=NULL;
      //printf("VariableName of new node %s, and value of new node %s \n",newNode->identifier,  newNode->stringValue);
      //addSetStatementToLinkedList(newNode);
      return newNode;   
}

void updateSetStatementIfGlobal(SetStatementNode * newSetStatement){
  //printf("FUNCTION: updateSetStatementIfGlobal\n");
  //printf("headOfMailBlocks is %s\n",headOfMailBlocks->mail);
  if(headToGlobalSetStatements==NULL){
    headToGlobalSetStatements= newSetStatement;    
  }
  else{
    newSetStatement->next=headToGlobalSetStatements; 
    headToGlobalSetStatements= newSetStatement;
  }
}

void addSetStatementToLinkedList(SetStatementNode * newSetStatement){
  //printf("FUNCTION: addSetStatementToLinkedList\n");
  if(headToSetStatements==NULL){
    //printf("headToSetStatements is null so I update it\n");
    headToSetStatements= newSetStatement;
  }
  else{
     //printf("HeadS is NOT null so I CREATE LINKED LIST\n");
    newSetStatement->next=headToSetStatements;
    headToSetStatements=newSetStatement;
  }

}

int checkIdentifier(char* ptr){
  //printf("FUNCTION: checkIdentifier\n");
 SetStatementNode * setStt = headToSetStatements;
  while(setStt!=NULL){
    //printf("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\n");
    if(strcmp(setStt->identifier,ptr) == 0){
      return 1;
    }
    setStt=setStt->next;
  }
  setStt= headToGlobalSetStatements;
  while(setStt!=NULL){
    //printf("BBBBBBBBBBBBBBBBBBBBBBBBB\n");
    if(strcmp(setStt->identifier,ptr) == 0){
      return 1;
    }
    setStt=setStt->next;
  }
  
  return -1;
 
}

char* findStringValueOfIdent(char* ptr){
   //printf("FUNCTION: findStringValueOfIdent\n");
  SetStatementNode * setStt = headToSetStatements;
  while(setStt!=NULL){
    if(strcmp(setStt->identifier,ptr) == 0){
      return(setStt->stringValue);
    }
    setStt=setStt->next;
  }
  setStt= headToGlobalSetStatements;
  while(setStt!=NULL){
    if(strcmp(setStt->identifier,ptr) == 0){
      return(setStt->stringValue);
    }
    setStt=setStt->next;
  }

}

RecipientNode * updateHead(RecipientNode* newNode){
  //printf("FUNCTION: updateHead\n");
  if(head==NULL){
    //printf("head is null so I initialized it\n");
    head= newNode;
    return head;
  }
  else{
    RecipientNode * current = head;
    while(current->next!=NULL){
      
      if(strcmp(current->email,newNode->email)==0){ 
      //printf("SAME EMAIL\n");      
        free(newNode);
        newNode=NULL;
        return head;
      }
      
      current = current->next;
    }    
     //printf("current email: %s, new email: %s \n", current->email, newNode->email);
     
    if(strcmp(current->email,newNode->email)==0){ 
      //printf("SAME EMAIL\n");     
        free(newNode);
        newNode=NULL;
        return head;
      }
      
    current->next=newNode;
    return newNode;
  }   
}

SendStatementNode*  updateHeadS(SendStatementNode* newNode){
  //printf("FUNCTION: updateHeadS\n");
  //printf("Updating updateHeadS\n");
  if(headS==NULL){
    //printf("HeadS is null so I update it\n");
    headS= newNode;
    return headS;
  }
  else{
     //printf("HeadS is NOT null so I CREATE LINKED LIST\n");
    SendStatementNode * current = headS;
    while(current->next!=NULL){
      current = current->next;
    }
    current->next=newNode;
    return newNode;
  }

}

RecipientNode * updateRecipientListHead(){
  //printf("FUNCTION: updateRecipientListHead\n");
    RecipientNode * newHead = (RecipientNode *)malloc(sizeof(RecipientNode));
    newHead->identifier = head->identifier;
    newHead->stringValue = head->stringValue;
    newHead->email = head->email;
    newHead->lineNum = head->lineNum;
    newHead->haveIdent=head->haveIdent;
    newHead->next =head->next;
    //printf("updateRecipientListHead is called with ident: %s string: %s email: %s\n",head->identifier,head->stringValue, head->email);
    return newHead;
}

SendStatementNode * updateSendStatementListHead(){
   //printf("FUNCTION: updateSendStatementListHead\n");
    SendStatementNode * newHead = (SendStatementNode *)malloc(sizeof(SendStatementNode));
    newHead->message = headS->message;
    newHead->ident=headS->ident;
    newHead->lineNum = headS->lineNum;
    newHead->head = headS->head;
    newHead->next = headS->next;
    
    //printf("updateSendStatementListHead is called with message: %s \n",headS->message);
    return newHead;
}

SetStatementNode * updateSetStatementListHead(){
   //printf("FUNCTION: updateSetStatementListHead\n");
   if(headToSetStatements!=NULL){
       //printf("FUNCTION: IM NOT NULL\n");

    SetStatementNode * newHead = (SetStatementNode *)malloc(sizeof(SetStatementNode));
    newHead->stringValue = headToSetStatements->stringValue;
    newHead->identifier = headToSetStatements->identifier;
    newHead->lineNum = headToSetStatements->lineNum;
    newHead->next = headToSetStatements->next;  
    //printf("updateSendStatementListHead is called with message: %s \n",headS->message);
    return newHead;
   }
   return NULL;
    
}

SendStatementNode * updateSendStatementListHeadInsideOfMailBlock(){
  if(headToAllSendStatements!=NULL){
    SendStatementNode * newHead = (SendStatementNode *)malloc(sizeof(SendStatementNode));
   
    newHead->message = headToAllSendStatements->message;
    
    newHead->ident=headToAllSendStatements->ident;
  
    newHead->lineNum = headToAllSendStatements->lineNum;

    if(headToAllSendStatements->head!=NULL){
    
       newHead->head = headToAllSendStatements->head;
    }
    else{
     
      newHead->head =NULL;
    }
    if(headToAllSendStatements->next!=NULL){
      
      newHead->next = headToAllSendStatements->next;
    }
    else{
    
      headToAllSendStatements->next=NULL;
    }
    return newHead;
  }
  else{
    return NULL;
  }
  
    
  
    
    
    //printf("updateSendStatementListHead is called with message: %s \n",headS->message);
    
}

ScheduleStatementNode * updateScheduleStatementHeadInsideOfMailBlock(){
   //printf("FUNCTION: updateScheduleStatementHeadInsideOfMailBlock\n");
   if(headToAllScheduleStatements!=NULL){
    //printf("FUNCTION: updateScheduleStatementHeadInsideOfMailBlock HEAD IS NOT NULL\n");
     ScheduleStatementNode * newHead = (ScheduleStatementNode *)malloc(sizeof(ScheduleStatementNode));
    newHead->date = headToAllScheduleStatements->date;
    newHead->time = headToAllScheduleStatements->time;
    newHead->head = headToAllScheduleStatements->head;
    newHead->next = headToAllScheduleStatements->next;
    return newHead;
   }
   else{
    //printf("FUNCTION: updateScheduleStatementHeadInsideOfMailBlock HEAD IS NULL\n");
    return NULL;
   }
   
}

RecipientNode * makeRecipientNodeFromIdent(IdentifierNode ident, MailNode mail){
  //printf("FUNCTION: makeRecipientNodeFromIdent\n");
      RecipientNode * newNode = (RecipientNode *)malloc(sizeof(RecipientNode));
      int isDefined = checkIdentifier(ident.variableName);
      if(isDefined==1){
        newNode->stringValue=findStringValueOfIdent(ident.variableName);
      }
      else{
          errorMessagesNode * errM = (errorMessagesNode *)malloc(sizeof(errorMessagesNode));
          errM->errMsg = ident.variableName;
          errM->lineNum = ident.lineNum;
          errM->isDate=0;
          errM->isTime=0;
          errM->isSet=1;
          errM->next=NULL;
          flagForError=1;
          addErrorMessageToTheLinkedList(errM);
      }
      newNode->identifier = ident.variableName;
      newNode->email = mail.email;
      newNode->haveIdent=1;
      newNode->lineNum = ident.lineNum;
      newNode->next =NULL;
      //printf("makeRecipientNodeFromIdent is called with ident: %s and email: %s  \n",newNode->identifier,  newNode->email);      
      return updateHead(newNode);
}

RecipientNode * makeRecipientNodeFromString(StringNode stringVar, MailNode mail){
  //printf("FUNCTION: makeRecipientNodeFromString\n");
      RecipientNode * newNode = (RecipientNode *)malloc(sizeof(RecipientNode));
      newNode->identifier = "";
      newNode->stringValue = stringVar.value;
      newNode->email = mail.email;
      newNode->haveIdent=0;
      newNode->lineNum = stringVar.lineNum;
      //printf("New node is created\n");
      //printf(" makeRecipientNodeFromString is called with string: %s and email: %s \n",newNode->stringValue,  newNode->email);
      return updateHead(newNode);
}

RecipientNode * makeRecipientNodeFromMail(MailNode mail){
  //printf("FUNCTION: makeRecipientNodeFromMail\n");
      RecipientNode * newNode = (RecipientNode *)malloc(sizeof(RecipientNode));
      newNode->identifier = "";
      newNode->stringValue = "";
      newNode->haveIdent=0;
      newNode->email = mail.email;
      newNode->lineNum = mail.lineNum;
      //printf("New node is created\n");
      //printf("makeRecipientNodeFromMail is called with email: %s \n", newNode->email);
      return updateHead(newNode);
}

SendStatementNode * createSendStatementWithMessageWithString(StringNode stringVar){
   //printf("FUNCTION: createSendStatementWithMessageWithString\n");
  //printf("Creating sendStatemnet with message\n");
  SendStatementNode * newNode = (SendStatementNode *)malloc(sizeof(SendStatementNode));
  newNode -> message = stringVar.value;
  newNode->ident.variableName="";
  newNode->ident.lineNum=stringVar.lineNum;
  newNode->head = updateRecipientListHead();
  newNode->next=NULL;
  head->next=NULL;
  free(head);
  head=NULL;
  return newNode;
  
}

SendStatementNode * createSendStatementWithMessageWithIdent(IdentifierNode identNew){
   //printf("FUNCTION: createSendStatementWithMessageWithIdent\n");
  //printf("Creating sendStatemnet with message\n");
  SendStatementNode * newNode = (SendStatementNode *)malloc(sizeof(SendStatementNode));
  int isDefined = checkIdentifier(identNew.variableName);
  if(isDefined==1){
        newNode ->message=findStringValueOfIdent(identNew.variableName);
  }
  else{
      errorMessagesNode * errM = (errorMessagesNode *)malloc(sizeof(errorMessagesNode));
      errM->errMsg = identNew.variableName;
      errM->lineNum = identNew.lineNum;
      errM->isDate=0;
      errM->isTime=0;
      errM->isSet=1;
      errM->next=NULL;
      flagForError=1;
      addErrorMessageToTheLinkedList(errM);
  }
  newNode->ident=identNew;
  newNode->lineNum=identNew.lineNum;
  newNode->head = updateRecipientListHead();
  newNode->next=NULL;
  head->next=NULL;
  free(head);
  head=NULL;
  return newNode;
  
}

ScheduleStatementNode * createScheduleStatement(DateNode  date, TimeNode  time){
   //printf("FUNCTION: createScheduleStatement\n");
  ScheduleStatementNode * newNode = (ScheduleStatementNode *)malloc(sizeof(ScheduleStatementNode));
  newNode->date = date;
  newNode->time=time;
  newNode->head = updateSendStatementListHead();
  newNode->next=NULL;
  if(headS!=NULL){
    headS->next=NULL;
    //free(headS);
    headS=NULL;
  }
  
  return newNode;
}

MailBlockAllNode * createMailBlockForSendAndSchedule(MailNode mailC){
  //printf("FUNCTION: createMailBlockForSendAndSchedule\n");
  MailBlockAllNode * newNode = (MailBlockAllNode *)malloc(sizeof(MailBlockAllNode));
  newNode->mail = mailC;
  //printf("THIS IS MAIL %s\n",mailC.email);
  //printf("I WILL CALL THE FUCTION BECAUSE I AM END OF THE MAIL FOR MAIL %s\n",mailC.email);
  
  newNode->headOfSchedule =updateScheduleStatementHeadInsideOfMailBlock();
 
  newNode->headOfSend=updateSendStatementListHeadInsideOfMailBlock();
  
  newNode->headOfSet =updateSetStatementListHead();

  if(headToAllSendStatements!=NULL){
    headToAllSendStatements->next=NULL;
     free(headToAllSendStatements);
  headToAllSendStatements=NULL;
  }
  if(headToAllScheduleStatements!=NULL){
    headToAllScheduleStatements->next=NULL;
     free(headToAllScheduleStatements);
    headToAllScheduleStatements=NULL;
  }
  if(headToSetStatements!=NULL){
    headToSetStatements->next=NULL;
     free(headToSetStatements);
    headToSetStatements=NULL;
  }
  
  newNode->next=NULL;
  return newNode;
}

SendStatementNode * addSendStatementToLinkedList(SendStatementNode * newSetStatement){
  //printf("FUNCTION: addSendStatementToLinkedList\n");
  if(headToAllSendStatements==NULL){
    //printf("HeadS is null so I update it\n");
    //printf("newset message: %s lineNum: %d ident: %s" ,newSetStatement->message,newSetStatement->lineNum,newSetStatement->ident.variableName );
    headToAllSendStatements= newSetStatement;
     //printf("headToAllSendStatements message: %s lineNum: %d ident: %s" ,headToAllSendStatements->message,headToAllSendStatements->lineNum,headToAllSendStatements->ident.variableName );
    return headToAllSendStatements;
  }
  else{
     //printf("HeadS is NOT null so I CREATE LINKED LIST\n");
    SendStatementNode * current = headToAllSendStatements;
    while(current->next!=NULL){
      current = current->next;
    }
    current->next=newSetStatement;
    return newSetStatement;
  }
  
}

ScheduleStatementNode * addScheduleStatementToLinkedList(ScheduleStatementNode * scheduleStatement){
  //printf("FUNCTION: addScheduleStatementToLinkedList\n");
    if(headToAllScheduleStatements==NULL){
    //printf("headToAllScheduleStatements is null so I update it\n");
    headToAllScheduleStatements= scheduleStatement;
    return headToAllScheduleStatements;
  }
  else{
     //printf("headToAllScheduleStatements is NOT null so I CREATE LINKED LIST\n");
    ScheduleStatementNode * current = headToAllScheduleStatements;
    while(current->next!=NULL){
      current = current->next;
    }
    current->next=scheduleStatement;
    return scheduleStatement;
  } 
}

MailBlockAllNode * addMailBlockToLinkedList(MailBlockAllNode * mailBlockAll){
  //printf("FUNCTION: addMailBlockToLinkedList\n");
    if(headOfMailBlocks==NULL){
    //printf("HeadS is null so I update it\n");
    headOfMailBlocks= mailBlockAll;
    return mailBlockAll;
  }
  else{
     MailBlockAllNode * current = headOfMailBlocks;
    while(current->next!=NULL){
      current = current->next;
    }
    current->next=mailBlockAll;
    return mailBlockAll;
  } 
}

void addErrorMessageToTheLinkedList(errorMessagesNode * errorM){
  //printf("FUNCTION: addErrorMessageToTheLinkedList\n");
  if(headToErrorMessages==NULL){
    headToErrorMessages= errorM;
  }
  else{
     
    errorM->next=headToErrorMessages;
    headToErrorMessages=errorM;
  } 
}

int isLeapYear(int year) {
  //printf("FUNCTION: isLeapYear\n");
    return ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0));
}
void checkDate(DateNode date){
  //printf("FUNCTION: checkDate\n");
  int daysInMonth[] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
  if (isLeapYear(date.year)) {
        daysInMonth[2] = 29;
  }
  if(date.month>12 || date.day>31 || (date.month ==2 && date.day>29) || date.month<1 || date.day<1){
    //printf("ERROR at line %d: date object is not correct (%s)\n",date.lineNum,date.originalDate);
    errorMessagesNode * errM = (errorMessagesNode *)malloc(sizeof(errorMessagesNode));
    errM->errMsg = date.originalDate;
    errM->lineNum = date.lineNum;
    errM->isDate=1;
    errM->isTime=0;
    errM->isSet=0;
    errM->next=NULL;
    flagForError=1;
    addErrorMessageToTheLinkedList(errM);
    //printf("%s\n",errM->errMsg);
  }

  else if(date.day > daysInMonth[date.month]){
     //printf("ERROR at line %d: date object is not correct (%s)\n",date.lineNum,date.originalDate);
     errorMessagesNode * errM = (errorMessagesNode *)malloc(sizeof(errorMessagesNode));
      errM->errMsg = date.originalDate;
      errM->lineNum = date.lineNum;
      errM->isDate=1;
      errM->isTime=0;
      errM->isSet=0;
      errM->next=NULL;
      flagForError=1;
      addErrorMessageToTheLinkedList(errM);
  }
}
void checkTime(TimeNode time){
  //printf("FUNCTION: checkTime\n");
  if(time.hour>=24 || time.minute >=60 || time.hour<0 || time.minute <0){
    //printf("ERROR at line %d: time object is not correct (%s)\n",time.lineNum,time.originalTime);
    errorMessagesNode * errM = (errorMessagesNode *)malloc(sizeof(errorMessagesNode));
    errM->errMsg = time.originalTime;
    errM->lineNum = time.lineNum;
    errM->isDate=0;
    errM->isTime=1;
    errM->isSet=0;
    errM->next=NULL;
    flagForError=1;
    addErrorMessageToTheLinkedList(errM);
    
  }
}

int main () 
{ 
   if (yyparse())
   {
      printf("ERROR\n");
      return 1;
    } 
    else 
    {
        //checkStatements();
        if(flagForError){
          printErrors();
        }
        else{
          printStatements();
        }
        
        return 0;
    } 

}