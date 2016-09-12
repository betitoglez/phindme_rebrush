<?php
/**
 * Created by PhpStorm.
 * User: Alberto
 * Date: 12/09/2016
 * Time: 17:47
 */

namespace App;


class Constants
{
    public static $DB_PERFECT = 1;
    public static $DB_NOT_MATCH = 0;
    public static $DB_GENERIC_FAIL = -1;
    public static $DB_UNCOMPLETE = -2;
    public static $DB_QUERY_FAIL = -3;
    public static $DB_TIMEOUT_FAIL = -4;
    public static $DB_CONNECTION_FAIL = -5;
    public static $DB_DUPLICATE_ENTRY = 2;
    public static $DB_MORE_ENTRIES = 3;

    public static $CN_NULL_EXCEPTION = 10;
    public static $CN_BAD_INPUT_DATA = 11;
    public static $CN_OPERATION_SUCCESFULL = 12;
    public static $CN_OPERATION_FAIL = 13;
    public static $CN_NETWORK_UNAVAILABLE = 15;
    public static $CN_DATA_NOT_EXISTS = 18;
    public static $CN_DATA_EXISTS = 19;

    public static $WEB_OK = 21;
    public static $WEB_FAIL = 23;

    public static $REGEX_ONE_WORD = "'^[a-zA-Z]\w+$'";
    public static $REGEX_TEXT = "'^(\w+\s?)*\w$'";
    public static $REGEX_MAIL = "'^[a-z][a-z0-9._-]*@([a-z0-9]+[.-])+[a-z]{2,4}$'";
    public static $REGEX_NAME = "'^[a-zA-Z\-\s,\.\(\)ÁÉÍÓÚÀÈÌÒÙביםףתüאטלעש×÷חÇסÑ]+$'";
    public static $REGEX_PHONE = "'^(\+|00\s?)?([1-9]\d{0,3})|(0[1-9]\d{0,2})?\s?-?(\(\+?\d+\))?(\s?\d\-?){1,16}\d$'";
    public static $REGEX_PASS_1GRADE="'^((?=.*[0-9a-zA-Z]).{1,24})$'";
    public static $REGEX_PASS_2GRADE="'^((?=.*\d)(?=.*[a-zA-Z])(?=.*[!/&?¿_¡.,@#$%])?.{6,24})$'";
    public static $REGEX_PASS_3GRADE="'^((?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!/&?¿_¡.,@#$%]).{8,24})$'";


    /** Literals */

    public static $NOT_VALID_USER  = "NOT_VALID_USER";
    public static $NOT_VALID_EMAIL = "NOT_VALID_EMAIL";
    public static $NOT_VALID_NAME  = "NOT_VALID_NAME";
}