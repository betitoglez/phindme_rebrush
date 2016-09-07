<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class InfoHi
 */
class InfoHi extends Model
{
    protected $table = 'info_his';

    public $timestamps = false;

    protected $fillable = [
        'id_User',
        'id_Contact',
        'info'
    ];

    protected $guarded = [];

        
}