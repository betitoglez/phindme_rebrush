<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class Contactsgroup
 */
class Contactsgroup extends Model
{
    protected $table = 'contactsgroup';

    public $timestamps = false;

    protected $fillable = [
        'id_Contact',
        'id_Group'
    ];

    protected $guarded = [];

        
}