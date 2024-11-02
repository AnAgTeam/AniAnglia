//
//  StringCvt.m
//  iOSAnixart
//
//  Created by Toilettrauma on 01.10.2024.
//

#import "StringCvt.h"

static const char abbrev[] = {'K', 'M', 'B'};

@implementation AbbreviateNumberFormatter

+(NSString *) stringFromNumber:(long long)num
{
    NSString *abbrevNum;
    float number = (float)num;

    //Prevent numbers smaller than 1000 to return NULL
    if (num >= 1000) {
        for (size_t i = sizeof(abbrev) - 1; i >= 0; i--) {

            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);

            if(size <= number) {
                // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
                number = number/size;
                NSString *numberString = [AbbreviateNumberFormatter floatToString:number];

                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%c", numberString, abbrev[i]];
                break;
            }

        }
    } else {

        // Numbers like: 999 returns 999 instead of NULL
        abbrevNum = [NSString stringWithFormat:@"%d", (int)number];
    }

    return abbrevNum;
}

+(NSString *) floatToString:(float) val {
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];

    while (c == 48) { // 0
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];

        //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
        if(c == 46) { // .
            ret = [ret substringToIndex:[ret length] - 1];
    }
}

    return ret;
}

@end
