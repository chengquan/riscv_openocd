
 extern void* jtagdpi_create(/* INPUT */const char* name, /* INPUT */int listen_port);

 extern void jtagdpi_tick(/* INPUT */void* ctx, /* OUTPUT */unsigned char *tck, /* OUTPUT */unsigned char *tms, /* OUTPUT */unsigned char *tdi, /* OUTPUT */unsigned char *trst_n, /* OUTPUT */unsigned char *srst_n, /* INPUT */unsigned char tdo);

 extern void jtagdpi_close(/* INPUT */void* ctx);
