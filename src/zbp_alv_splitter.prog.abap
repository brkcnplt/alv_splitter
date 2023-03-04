********************************************************************************
* GitHub Repository : https://www.github.com/brkcnplt
* Linkedin          : https://www.linkedin.com/in/berkcanpolat/
********************************************************************************
* ALV Splitter Example
* Berk Can Polat - 04.03.2023 11:02:45
********************************************************************************
REPORT zbp_alv_splitter.



CLASS lcl_initialzation DEFINITION.

  PUBLIC SECTION.

    CONSTANTS: lc_container TYPE scrfname VALUE 'ZCUSTOM_CONTAINER'.
    DATA: lo_cust_container TYPE REF TO cl_gui_custom_container,
          lo_container1     TYPE REF TO cl_gui_container,
          lo_container2     TYPE REF TO cl_gui_container,
          lo_splitter       TYPE REF TO cl_gui_splitter_container,
          lo_grid1          TYPE REF TO cl_gui_alv_grid,
          lo_grid2          TYPE REF TO cl_gui_alv_grid.

    TYPES: BEGIN OF ty_data1,
             matnr TYPE mara-matnr,
             mtart TYPE mara-mtart,
             meins TYPE mara-meins,
             gewei TYPE mara-gewei,
           END OF ty_data1.
    DATA: ls_data1 TYPE ty_data1,
          lt_data1 TYPE TABLE OF ty_data1,
          lt_data2 TYPE TABLE OF makt,
          lt_fcat  TYPE lvc_t_fcat,
          ls_fcat  TYPE lvc_s_fcat.


    METHODS: constructor,
      get_data_for_container1,
      get_data_for_container2 IMPORTING it_data1 TYPE ANY TABLE.

ENDCLASS.


CLASS lcl_initialzation IMPLEMENTATION.
  METHOD constructor.

    CREATE OBJECT lo_cust_container
      EXPORTING
        container_name = lc_container.

    CREATE OBJECT lo_splitter
      EXPORTING
        parent  = lo_cust_container
        rows    = 1
        columns = 2.


    lo_splitter->get_container( EXPORTING row = 1 column = 1 RECEIVING container = lo_container1 ).
    lo_splitter->get_container( EXPORTING row = 1 column = 2 RECEIVING container = lo_container2 ).


  ENDMETHOD.

  METHOD get_data_for_container1.

    DEFINE append_fcat.
      CLEAR ls_fcat.
      ls_fcat-col_pos = &1.
      ls_fcat-fieldname = &2.
      ls_fcat-outputlen = '25'.
      ls_fcat-scrtext_l = &3.
      APPEND ls_fcat TO lt_fcat.
      CLEAR ls_fcat.
    END-OF-DEFINITION.


    CREATE OBJECT lo_grid1  "to display alv assign the container object
      EXPORTING
        i_parent = lo_container1.

    SELECT matnr,
           mtart,
           meins,
           gewei
      FROM mara
      INTO TABLE @lt_data1
      WHERE mtart = 'HALB'.


    REFRESH lt_fcat.
    append_fcat: '1' 'MATNR' 'Malzeme No',
                 '2' 'MTART' 'Malzeme Türü',
                 '3' 'MEINS' 'Temel Ölçü Birimi',
                 '4' 'GEWEI' 'Ağırlık Birimi'.

    lo_grid1->set_table_for_first_display(
   EXPORTING
     is_layout       = VALUE lvc_s_layo( zebra = 'X' cwidth_opt = 'X' )
   CHANGING
     it_fieldcatalog = lt_fcat
     it_outtab       = lt_data1 ).


  ENDMETHOD.

  METHOD get_data_for_container2.

    CREATE OBJECT lo_grid2
      EXPORTING
        i_parent = lo_container2.

    IF lines( lt_data1 ) GT 0.


      SELECT *
        FROM makt
        INTO TABLE @lt_data2
        FOR ALL ENTRIES IN @lt_data1
        WHERE matnr = @lt_data1-matnr.

      REFRESH lt_fcat.
      append_fcat: '1' 'MATNR' 'Malzeme No',
                   '2' 'MAKTX' 'Malzeme Metni',
                   '3' 'MAKTG' 'Metin2'.

      lo_grid2->set_table_for_first_display(
     EXPORTING
       is_layout       = VALUE lvc_s_layo( zebra = 'X' cwidth_opt = 'X' )
     CHANGING
       it_fieldcatalog = lt_fcat
       it_outtab       = lt_data2 ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.


END-OF-SELECTION.


  CALL SCREEN 0100.




MODULE status_0100 OUTPUT.

  SET PF-STATUS 'STANDARD'.

  DATA(lo_display) = NEW lcl_initialzation( ).

  CHECK lo_display IS BOUND.

  TRY .


      lo_display->get_data_for_container1( ).
      lo_display->get_data_for_container2( EXPORTING it_data1 = lo_display->lt_data1 ).

    CATCH cx_root INTO DATA(lo_exception) .
      MESSAGE lo_exception->get_text( ) TYPE 'E'.
  ENDTRY.


ENDMODULE.
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN '&F12' OR '&F15' OR '&F03'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
