<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class Usertemp
 */
class Usertemp extends Model
{
    protected $table = 'usertemp';

    public $timestamps = false;

    protected $fillable = [
        'user',
        'mail',
        'phone',
        'name',
        'sign_date',
        'key'
    ];

    protected $guarded = [];

        
}