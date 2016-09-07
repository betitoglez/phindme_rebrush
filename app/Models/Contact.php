<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class Contact
 */
class Contact extends Model
{
    protected $table = 'contacts';

    public $timestamps = false;

    protected $fillable = [
        'id_User',
        'id_Contact',
        'name',
        'name_privacy',
        'mail',
        'mail_privacy',
        'privacy'
    ];

    protected $guarded = [];

        
}