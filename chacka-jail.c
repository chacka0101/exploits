#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>

int main(int argc, char ** argv){
    setuid(1000);

    char line[101];

    FILE *fp = fopen (argv[1], "r");

 while(fgets(line, 100, fp) != NULL)
 {
  puts(line);
 }

 fclose(fp);
}
