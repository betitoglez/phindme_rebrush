<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class Infocontact
 */
class Infocontact extends Model
{
    protected $table = 'infocontact';

    public $timestamps = false;

    protected $fillable = [
        'id_Info',
        'id_Contact'
    ];

    protected $guarded = [];

        
}