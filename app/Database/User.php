<?php
/**
 * Created by PhpStorm.
 * User: Alberto
 * Date: 12/09/2016
 * Time: 17:18
 */

namespace App\Database;


class User extends AbstractDatabase
{

    public function test ()
    {
        var_dump($this->call("GetContact",array(1,2)));
    }
}