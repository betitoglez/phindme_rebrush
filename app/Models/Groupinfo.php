<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Class Groupinfo
 */
class Groupinfo extends Model
{
    protected $table = 'groupinfo';

    public $timestamps = false;

    protected $fillable = [
        'id_Group',
        'id_Info'
    ];

    protected $guarded = [];

        
}