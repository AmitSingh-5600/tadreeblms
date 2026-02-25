<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Course;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

/**
 * Creates sample categories and courses so the "Recent Courses (Last 10 Created)"
 * dashboard table can be viewed with real data (for testing layout/CSS).
 * Run: php artisan db:seed --class=DemoCoursesSeeder --force
 */
class DemoCoursesSeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name' => 'Programming', 'slug' => 'programming', 'status' => 1],
            ['name' => 'Business', 'slug' => 'business', 'status' => 1],
            ['name' => 'Design', 'slug' => 'design', 'status' => 1],
        ];

        foreach ($categories as $cat) {
            Category::firstOrCreate(
                ['slug' => $cat['slug']],
                array_merge($cat, ['icon' => null])
            );
        }

        $categoryIds = Category::pluck('id')->toArray();
        $teacherId = 2; // teacher@lms.com from UserTableSeeder

        $titles = [
            'Laravel Basics', 'PHP 8 Fundamentals', 'Vue.js Intro', 'REST APIs',
            'Project Management', 'Leadership Skills', 'Marketing 101', 'UX Design',
            'CSS Grid Layout', 'JavaScript ES6+', 'Database Design', 'DevOps Intro',
        ];

        foreach ($titles as $i => $title) {
            $slug = Str::slug($title) . '-' . ($i + 1);
            if (Course::where('slug', $slug)->exists()) {
                continue;
            }
            $course = Course::create([
                'category_id'  => $categoryIds[$i % count($categoryIds)],
                'title'        => $title,
                'slug'         => $slug,
                'description'  => 'Sample description for demo.',
                'price'        => 0,
                'published'    => $i % 2,
                'free'         => 1,
                'start_date'   => now()->addDays(7)->format('Y-m-d'),
                'created_at'   => Carbon::now()->subDays(count($titles) - 1 - $i),
                'updated_at'   => Carbon::now()->subDays(count($titles) - 1 - $i),
            ]);
            if (!$course->teachers()->where('user_id', $teacherId)->exists()) {
                $course->teachers()->attach($teacherId);
            }
        }
    }
}
