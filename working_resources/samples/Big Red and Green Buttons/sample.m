UIButton *sampleButton = [UIButton buttonWithType:UIButtonTypeCustom];
[sampleButton setFrame:[cell.contentView frame]];
[sampleButton setFrame:CGRectMake(0, 0, cell.bounds.size.width-20, 44)];
[sampleButton setBackgroundImage:[UIImage imageNamed:@"button_red.png"] forState:UIControlStateNormal];
[cell addSubview:sampleButton];


UIImage* greenButton = [UIImage imageNamed:@"UIButton_green.png"]; 
UIImage *newImage = [greenButton stretchableImageWithLeftCapWidth:greenButton.size.width/2 topCapHeight:greenButton.size.height/2];
[callButton setBackgroundImage:newImage forState:UIControlStateNormal];


