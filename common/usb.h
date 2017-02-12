unsigned char readbuff[USB_REPORT_SIZE]  absolute 0x500;                        // Buffers should be in USB RAM, please consult datasheet
unsigned char writebuff[USB_REPORT_SIZE] absolute 0x500 + USB_REPORT_SIZE;

void usb_on( )
{
    HID_Enable(&readbuff, &writebuff);
}

char usb_read( )
{
    return HID_Read();
}

char usb_write( )
{
    return HID_Write(&writebuff, USB_REPORT_SIZE);
}

void usb_off( )
{
    HID_Disable();
}
