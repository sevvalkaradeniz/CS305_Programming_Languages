#ifndef __MS_H
#define __MS_H
#include <stdbool.h>

typedef struct IdentifierNode
{
   char *variableName;
   int lineNum;
} IdentifierNode;

typedef struct StringNode{
    char *value;
   int lineNum;
}StringNode;

typedef struct MailNode{
    char* email;
    int lineNum;
}MailNode;

typedef struct SetStatementNode
{
    char *stringValue;
    char *identifier;
    int lineNum;
    struct SetStatementNode * next;
} SetStatementNode;

typedef struct RecipientNode{
    char* identifier;
    char* stringValue;
    char* email;    
    int lineNum;
    int haveIdent;
    struct RecipientNode* next;
}RecipientNode;


typedef struct SendStatementNode{
    struct IdentifierNode ident; 
    char* message;
    int lineNum;
    struct RecipientNode* head;
    struct SendStatementNode* next;
}SendStatementNode;

typedef struct DateNode{
    int day;
    int month;
    int year;
    int lineNum;
    char* originalDate;
}DateNode;

typedef struct TimeNode{
    int hour;
    int minute;
    int lineNum;
    char* originalTime;
}TimeNode;

typedef struct ScheduleStatementNode{
    struct DateNode  date;
    struct TimeNode  time;
    struct MailNode messageOfMail;
    struct SendStatementNode* head;
    struct ScheduleStatementNode * next;
}ScheduleStatementNode;

typedef struct MailBlockAllNode{
    struct MailNode mail;
    struct ScheduleStatementNode* headOfSchedule;
    struct SendStatementNode* headOfSend;
    struct MailBlockAllNode *next;
    struct SetStatementNode * headOfSet;
}MailBlockAllNode;

typedef struct errorMessagesNode{
    int lineNum;
    char * errMsg;
    int isDate;
    int isTime;
    int isSet;
    struct errorMessagesNode * next;
}errorMessagesNode;


#endif