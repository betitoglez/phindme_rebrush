<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class Friendrequest
 */
class Friendrequest extends Model
{
    protected $table = 'friendrequest';

    public $timestamps = false;

    protected $fillable = [
        'id_User',
        'id_Contact'
    ];

    protected $guarded = [];

        
}