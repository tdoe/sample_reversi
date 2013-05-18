//
//  ViewController.m
//  sample
//
//  Created by tdoe on 2013/05/11.
//  Copyright (c) 2013年 tdoe. All rights reserved.
//

#import "ViewController.h"

#import "OseroFactory.h"

#import "StoneLabel.h"

@interface ViewController ()

@end

@implementation ViewController

//何手目かカウントする
int turnCount;

//どちらの番か示すフラグ
int bothSide;

//盤面の石の配列
NSMutableArray *stones;

//戻すようの石の場所をスタックする配列
NSMutableArray *undoStack;

//進むようの石の場所をスタックする配列
NSMutableArray *redoStack;

//走査する方向
NSMutableArray *lineIndex;

-(void)bot:(NSMutableArray *)array
{
    NSNumber *num = [array lastObject];
    int index = [num intValue];
    UILabel *label = [stones objectAtIndex:index];
    int result = [self flip:label];
    if(result != 0){
        redoStack = [NSMutableArray array];
    }
}

/**
 * Viewをタッチした時に呼ばれるメソッド
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    
    if(touch.view.backgroundColor == [UIColor greenColor]
       ||
       touch.view.backgroundColor == [UIColor grayColor]){
        int result = [self flip:touch.view];
        if(result != 0){
            redoStack = [NSMutableArray array];
        }
    }
}

/**
 * 石をおいた時の処理
 */
-(int) flip:(UIView *)view
{
    int tag = view.tag;
    int result = 0;
    NSMutableArray *stack = [NSMutableArray array];
    
    //8方向走査
    for (NSNumber *index in lineIndex) {
        int line = [index intValue];
        result += [self flipLine:tag:line:stack];
    }
    
    if(result != 0){

        [self changeStoneColor:stones[tag]];
        [stack addObject:[NSNumber numberWithInt:tag]];
        
        for (NSNumber *indexNum in stack) {
            int index = [indexNum intValue];
            [self changeStoneColor:[stones objectAtIndex:index]];
        }

        [self changeCount];
        [undoStack addObject:stack];
        turnCount++;
    }
    
    return result;
}

-(void) chagnePlan
{
    NSMutableArray *indexes = [NSMutableArray array];
    
    for (UILabel *stone in stones) {
        
        if(stone.backgroundColor == [UIColor grayColor]){
            stone.backgroundColor = [UIColor greenColor];
        }

        if(stone.backgroundColor == [UIColor greenColor]){
            continue;
        }
        
        if(bothSide == 0){
            if(stone.backgroundColor == [UIColor whiteColor]){
                [indexes addObject:[NSNumber numberWithInt:stone.tag]];
            }
        }else if(bothSide == 1){
            if(stone.backgroundColor == [UIColor blackColor]){
                [indexes addObject:[NSNumber numberWithInt:stone.tag]];
            }
        }
    }
    
    NSMutableArray *array = [NSMutableArray array];
    
    int result = 0;
    
    for (NSNumber *indexNum in indexes) {
        
        int index = [indexNum intValue];
        
        for (NSNumber *lineLine in lineIndex) {
        
            int line = [lineLine intValue];
            
            for (NSNumber *lineLine2 in lineIndex) {
                int line2 = [lineLine2 intValue];
                int index2 = index + line2;
                UILabel *label2 = [stones objectAtIndex:index2];
                if(label2.backgroundColor != [UIColor greenColor]){
                    continue;
                }
                result += [self flipCheck:index + line2:line:array];
            }
        }
    }
    
    if(result == 0){
        [self alert:@"パスするしかありません"];
    }else{
        for (NSNumber *indexNum in array) {
            int index = [indexNum intValue];
            
            UILabel *label = [stones objectAtIndex:index];
            label.backgroundColor = [UIColor grayColor];
        }
        if(bothSide == 1){
            [self bot: array];
        }
    }
}

-(int)flipCheck:(int)point :(int)line :(NSMutableArray *)array
{
    if([self isWall:point]){
        return 0;
    }
    
    int index = point + line;

    UILabel *targetLabel = [stones objectAtIndex:index];
    
    BOOL isHit = false;
    while(targetLabel.backgroundColor == [self getVsSideColor]){
        isHit = true;
        index += line;
        targetLabel = [stones objectAtIndex:index];
    }
    
    if(targetLabel.backgroundColor == [self getOwnSideColor]){
        if(isHit){
            [array addObject:[NSNumber numberWithInt:point]];
            return 1;
        }
    }
    
    return 0;
}

/**
 * ひっくり返す石の位置を返す。
 */
-(int) flipLine:(int)point :(int)line :(NSMutableArray *) stack
{
    //変更した石の数
    int result = 0;
    
    //検査する石の位置
    int index = point + line;
    
    if([self isWall:index]){
        return 0;
    }
    
    //検査する石
    UILabel *targetLabel = stones[index];
    
    //検査中の石の色と相手側の石の色が一致すれば再検査
    while(targetLabel.backgroundColor == [self getVsSideColor]){
        index += line;
        targetLabel = stones[index];
    }
    
    if(targetLabel.backgroundColor != [self getOwnSideColor]){
        return 0;
    }
    
    index -= line;
    
    while(point != index){
        [stack addObject:[NSNumber numberWithInt:index]];
        result++;

        index -= line;
    }

    return result;
}

/**
 * 盤面を初期化する。
 */
- (void) initBorad
{
    bothSide = 1;
    turnCount = 0;
    
    stones = [NSMutableArray array];
    undoStack = [NSMutableArray array];
    redoStack = [NSMutableArray array];

    int tag = 0;
    
    for (int i = 0; i < 10; i++) {
        for(int j = 0; j < 10; j++){
            
            NSString *text = [NSString stringWithFormat:@"%d", tag];
            StoneLabel *stoneLabel = [OseroFactory createStoneLabel:text :tag :i :j];
            
            if([self isWall:tag]){
                stoneLabel.hidden = true;
            }

            [self.view addSubview:stoneLabel];
            [stones addObject:stoneLabel];
            
            tag++;
        }
    }
    
    [self changeCount];
}

/**
 * 引数で渡された石の色を変更する。
 */
- (void)changeStoneColor:(UILabel *)label
{
    if(bothSide == 0){
        label.backgroundColor = [UIColor blackColor];
    }else{
        label.backgroundColor = [UIColor whiteColor];
    }
}

/**
 * 白と黒の石の数を数えて表示する。
 */
-(void) changeCount
{
    int black = 0;
    int white = 0;
    for (UILabel *stone in stones) {
        if(stone.backgroundColor == [UIColor blackColor]){
            black++;
        }else if(stone.backgroundColor == [UIColor whiteColor]){
            white++;
        }
    }
    self.blacCount.text = [NSString stringWithFormat:@"%d", black];
    self.whiteCount.text = [NSString stringWithFormat:@"%d", white];
    
    if(black == 0){
        self.bothSideLabel.text = @"パーフェクト！白の勝ち！";
        return;
    }else if(white == 0){
        self.bothSideLabel.text = @"パーフェクト！黒の勝ち！";
        return;
    }

    if(black + white == 64){
        if(black == white){
            self.bothSideLabel.text = @"引き分け";
        }else if(black > white){
            self.bothSideLabel.text = @"黒の勝ち";
        }else{
            self.bothSideLabel.text = @"白の勝ち";
        }
    }else{
        bothSide = bothSide == 0 ? 1 : 0;
        self.bothSideLabel.text = bothSide == 0 ? @"黒の番" : @"白の番";
        
        [self chagnePlan];
    }
}

/**
 * 現在のターンの色を返す。
 */
-(UIColor *) getOwnSideColor{
    UIColor *color;
    if(bothSide == 0){
        color = [UIColor blackColor];
    }else{
        color = [UIColor whiteColor];
    }
    return color;
}

/**
 * 現在のターンの色を返す。
 */
-(UIColor *) getVsSideColor{
    UIColor *color;
    if(bothSide == 0){
        color = [UIColor whiteColor];
    }else{
        color = [UIColor blackColor];
    }
    return color;
}

/**
 * 座標が壁かどうかを返す。
 */
-(Boolean) isWall:(int)point
{
    return (point <= 9 || point % 10 == 0 || point > 90 || (point + 1) % 10 == 0);
}

- (void) alert:(NSString *)string
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"タイトル"
     message:string
     delegate:nil
     cancelButtonTitle:nil
     otherButtonTitles:@"OK", nil
     ];
    
    [alert show];
}

/**
 * 押されたら現在のターンを入れ替える
 */
- (IBAction)passButton:(id)sender {
    [self changeCount];
}

/**
 * ひとつ進むボタンを押したら
 * 戻したターンをひとつ進める
 */
- (IBAction)redoButton:(id)sender {
    
    //進められるスタックが無ければ終了
    if([redoStack count] == 0){
        return;
    }
    
    //進める(置き直す)石の位置を取得
    NSNumber *index = [redoStack lastObject];
    int lastIndex = [index intValue];
    
    //石を置き直す
    [self flip:[stones objectAtIndex:lastIndex]];
    
    //スタックを一つ消す
    [redoStack removeObject:index];
}

/**
 * ひとつ戻すボタンを押したらターンをひとつ戻す
 */
- (IBAction)undoButton:(id)sender {
    
    //進められるスタックが無ければ終了
    if([undoStack count] == 0){
        return;
    }
    
    //戻す石の位置を取得
    NSArray *stack = [undoStack lastObject];
    
    //黒<->白を入れ替える
    for (NSNumber *index in stack) {
        int ind = [index intValue];
        
        UILabel *label = [stones objectAtIndex:ind];
        
        [self changeStoneColor:label];
    }
    
    //最後の石は一番最初に置いた石なので緑に戻す
    NSNumber *lastIndex = [stack lastObject];
    int ind = [lastIndex intValue];
    UILabel *label = [stones objectAtIndex:ind];
    label.backgroundColor = [UIColor greenColor];
    
    //戻すスタックを一つ削除し
    //進むスタックを1つ追加
    [undoStack removeObject:stack];
    [redoStack addObject:lastIndex];
    
    //盤面の石数を数え直す
    [self changeCount];
}

/**
 * Resetボタンを押した時の処理
 */
- (IBAction)resetButton:(id)sender
{
    [self initBorad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * ロード時に一度だけ呼ばれるメソッド
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    lineIndex = [NSMutableArray array];
    [lineIndex addObject:[NSNumber numberWithInt:-11]];
    [lineIndex addObject:[NSNumber numberWithInt:-10]];
    [lineIndex addObject:[NSNumber numberWithInt:-9]];
    [lineIndex addObject:[NSNumber numberWithInt:-1]];
    [lineIndex addObject:[NSNumber numberWithInt:1]];
    [lineIndex addObject:[NSNumber numberWithInt:9]];
    [lineIndex addObject:[NSNumber numberWithInt:10]];
    [lineIndex addObject:[NSNumber numberWithInt:11]];

    [self initBorad];
}

@end
