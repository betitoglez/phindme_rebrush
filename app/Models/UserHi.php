<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class UserHi
 */
class UserHi extends Model
{
    protected $table = 'user_his';

    public $timestamps = false;

    protected $fillable = [
        'id_User',
        'user',
        'name',
        'mail'
    ];

    protected $guarded = [];

        
}