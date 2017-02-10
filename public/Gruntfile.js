module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    riot: {
      options: {
          concat : true
      },
      src: ['**/*.tag'],
      dest: './all-tags.js'
    },
    watch: {
      scripts: {
        files: ['**/*.tag'],
        tasks: ['riot'],
        options: {
          spawn: false
        }
      }
    }
  })

  // Load the plugin that provides the "grunt-riot" task.
  grunt.loadNpmTasks('grunt-riot');
  grunt.loadNpmTasks('grunt-contrib-watch');

  // Default task(s).
  grunt.registerTask('default', ['riot']);

};