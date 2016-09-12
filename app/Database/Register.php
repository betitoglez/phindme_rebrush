<?php
/**
 * Created by PhpStorm.
 * User: Alberto
 * Date: 12/09/2016
 * Time: 17:18
 */

namespace App\Database;


class Register extends AbstractDatabase
{

    public function isValidPass($item)
    {
        if($item==null || $item==''){
            $result = 0;}// 0 - Si es vacía
        elseif(strpos($item,' ')!==false){
            $result = -1;}// -1 - Si contiene espacios
        else{
            try{
                if(preg_match(\App\Constants::$REGEX_PASS_3GRADE,$item)==1){
                    $result=3;}// 3 - Cumple el tercer grado de bondad
                elseif(preg_match(\App\Constants::$REGEX_PASS_2GRADE,$item)==1){
                    $result=2;}// 2 - Cumple el segundo grado de bondad
                elseif(preg_match(\App\Constants::$REGEX_PASS_1GRADE,$item)==1){
                    $result=1;}// 1 - Cumple el primer grado de bondad
                else{
                    $result=4;}// 4 - Si no cumple ninguno
            }
            catch(Exception $ex){
                //Control errores
                //generic::controlErrores($ex);
                $result=-5;
            }
        }
        return $result;
    }

    public function isValidUser($val)
    {
        $result = $this->call("EXISTS_USER",$val);

        switch($result){
            case 1:$result    = \App\Constants::$CN_DATA_EXISTS;break;
            case 0:$result    = \App\Constants::$CN_DATA_NOT_EXISTS;break;
            default:$result   = \App\Constants::$CN_OPERATION_FAIL;break;
        }

        return $result;

    }

    public function isValidName($val)
    {
        return ($val=='' || preg_match(\App\Constants::$REGEX_NAME,$val)==1)?TRUE:\App\Constants::$NOT_VALID_NAME;
    }

    public function isValidMail($val)
    {
        return preg_match(\App\Constants::$REGEX_MAIL, $val)==1?TRUE:\App\Constants::$NOT_VALID_EMAIL;
    }

    public function isValidMailExists($val)
    {
        $caso= $this->call('EXISTS_MAIL',$val);
        var_dump($caso);
        switch($caso){
            case 1:$result = \App\Constants::$CN_DATA_EXISTS;break;
            case 0:$result = \App\Constants::$CN_DATA_NOT_EXISTS;break;
            default:$result= \App\Constants::$CN_OPERATION_FAIL;break;
        }
        return $result;
    }

}