<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class ContactsHi
 */
class ContactsHi extends Model
{
    protected $table = 'contacts_his';

    public $timestamps = false;

    protected $fillable = [
        'id_User',
        'id_Contact',
        'name',
        'mail'
    ];

    protected $guarded = [];

        
}