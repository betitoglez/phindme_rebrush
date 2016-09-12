<?php
/**
 * Created by PhpStorm.
 * User: Alberto
 * Date: 12/09/2016
 * Time: 16:48
 */

namespace App\Database;


use Illuminate\Support\Facades\DB;

abstract class AbstractDatabase
{


    /**
     * @return \PDO $oPDO
     */
    private function getPdoAdapter()
    {
        return DB::connection()->getPdo();
    }


    protected function call ($sName, $aParams = array() , $sType = "PROC")
    {
        if (!is_array($aParams)){
            $aParams = (array) $aParams;
        }

        $sQuestionTag  = count($aParams)>0?substr(($_aux=str_repeat("?,",count($aParams))),0,strlen($_aux)-1):'';
        $sPrepareQuery =  ($sType!="PROC"?"SELECT":"CALL") . " $sName (" . $sQuestionTag . ")";

        $oPDO = $this->getPdoAdapter();
        $query = $oPDO->prepare($sPrepareQuery);

        if (count($aParams)>0){
            $i=0;
            foreach($aParams as $_param){
                $i++;
                $query->bindValue($i,$_param,\PDO::PARAM_STR);
            }
        }

        $query->execute();

        if ($sType != "PROC"){
            $result = $query->fetchAll(\PDO::FETCH_ASSOC);
            return $result;
        }

    }
}