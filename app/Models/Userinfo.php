<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class Userinfo
 */
class Userinfo extends Model
{
    protected $table = 'userinfo';

    public $timestamps = false;

    protected $fillable = [
        'id_User',
        'id_Info',
        'privacy'
    ];

    protected $guarded = [];

        
}