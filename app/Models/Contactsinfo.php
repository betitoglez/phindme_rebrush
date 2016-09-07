<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class Contactsinfo
 */
class Contactsinfo extends Model
{
    protected $table = 'contactsinfo';

    public $timestamps = false;

    protected $fillable = [
        'id_User',
        'id_Contact',
        'id_Info'
    ];

    protected $guarded = [];

        
}