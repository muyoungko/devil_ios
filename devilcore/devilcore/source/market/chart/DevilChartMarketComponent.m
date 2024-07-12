//
//  DevilChartMarketComponent.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/09/29.
//

#import "DevilChartMarketComponent.h"
#import "MappingSyntaxInterpreter.h"
#import "WildCardUtil.h"
#import "WildCardConstructor.h"

@import Charts;

@interface DevilChartMarketComponent()
<ChartViewDelegate, ChartValueFormatter, ChartAxisValueFormatter>
@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSString* dataPath;
@property (nonatomic, retain) BarLineChartViewBase* chart;
@property (nonatomic, retain) PieChartView* pie_chart;
@property (nonatomic, retain) NSMutableArray* list;

@end

@implementation DevilChartMarketComponent
- (void)initialized {
    [super initialized];
    
    self.type = self.marketJson[@"select3"];
    self.dataPath = self.marketJson[@"select2"];
    
    if([@"bar" isEqualToString:self.type]) {
        self.chart = [[BarChartView alloc] init];
        ((BarChartView*)_chart).drawBarShadowEnabled = NO;
        ((BarChartView*)_chart).drawValueAboveBarEnabled = YES;
        [self createBarChart];
    } else if([@"line" isEqualToString:self.type]) {
        self.chart = [[LineChartView alloc] init];
        [self createBarChart];
    } else if([@"pie" isEqualToString:self.type]) {
        self.pie_chart = [[PieChartView alloc] init];
        [self createPieChart];
    }
    
    
}

- (void) createPieChart {
    [self.vv addSubview:self.pie_chart];
    [WildCardConstructor followSizeFromFather:self.vv child:self.pie_chart];
    
    PieChartView* chartView = self.pie_chart;
    
    chartView.usePercentValuesEnabled = YES;
    chartView.drawSlicesUnderHoleEnabled = NO;
    chartView.holeRadiusPercent = 0.58;
    chartView.transparentCircleRadiusPercent = 0.61;
    chartView.chartDescription.enabled = NO;
    [chartView setExtraOffsetsWithLeft:5.f top:10.f right:5.f bottom:5.f];
    
    chartView.drawCenterTextEnabled = YES;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    
    chartView.drawHoleEnabled = YES;
    chartView.rotationAngle = 0.0;
    chartView.rotationEnabled = YES;
    chartView.highlightPerTapEnabled = YES;
    
    ChartLegend *l = chartView.legend;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentRight;
    l.verticalAlignment = ChartLegendVerticalAlignmentTop;
    l.orientation = ChartLegendOrientationVertical;
    l.drawInside = NO;
    l.xEntrySpace = 7.0;
    l.yEntrySpace = 0.0;
    l.yOffset = 0.0;
    chartView.delegate = self;
    
    // entry label styling
    chartView.entryLabelColor = UIColor.blackColor;
    chartView.entryLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
    
    //    _sliderX.value = 4.0;
    //    _sliderY.value = 100.0;
    [self slidersValueChanged:nil];
    
    [chartView animateWithXAxisDuration:1.4 easingOption:ChartEasingOptionEaseOutBack];
}

- (IBAction)slidersValueChanged:(id)sender
{
    //    _sliderTextX.text = [@((int)_sliderX.value) stringValue];
    //    _sliderTextY.text = [@((int)_sliderY.value) stringValue];
    
}

- (void) createBarChart {
    _chart.delegate = self;
    
    [self.vv addSubview:self.chart];
    [WildCardConstructor followSizeFromFather:self.vv child:self.chart];
    
    _chart.chartDescription.enabled = NO;
    _chart.maxVisibleCount = 60;
    _chart.pinchZoomEnabled = NO;
    _chart.drawGridBackgroundEnabled = NO;
    
    _chart.xAxis.labelPosition = XAxisLabelPositionBottom;
    _chart.xAxis.drawGridLinesEnabled = YES;
    _chart.xAxis.granularity = 1.0f;
    _chart.xAxis.centerAxisLabelsEnabled = NO;
    _chart.xAxis.labelFont = [UIFont systemFontOfSize:11.f];
    
    _chart.leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    _chart.leftAxis.labelFont = [UIFont systemFontOfSize:11.f];
    
    ChartYAxis *rightAxis = _chart.rightAxis;
    rightAxis.enabled = YES;
    rightAxis.drawGridLinesEnabled = NO;
    rightAxis.labelFont = [UIFont systemFontOfSize:10.f];
    rightAxis.labelCount = 8;
    rightAxis.spaceTop = 0.15;
    rightAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
    rightAxis.valueFormatter = self;
    
    ChartLegend *l = _chart.legend;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentLeft;
    l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
    l.orientation = ChartLegendOrientationHorizontal;
    l.drawInside = NO;
    l.form = ChartLegendFormSquare;
    l.formSize = 9.0;
    l.font = [UIFont systemFontOfSize:14.f];
    l.xEntrySpace = 4.0;
    
    _chart.extraTopOffset = 8.0f;
    _chart.extraRightOffset = 8.0f;
    _chart.extraBottomOffset = 8.0f;
}

- (void)update:(JSValue*)opt {
    [super update:opt];
    
    if([@"bar" isEqualToString:self.type] || [@"line" isEqualToString:self.type]) {
        [self updateBarChart:opt];
    } else if([@"pie" isEqualToString:self.type]){
        [self updatePieChart:opt];
    }
}

- (void)updatePieChart:(id)opt {
    
    id DEFAULT_COLOR_LIST = @[@"#6597EA",
                              @"#9AB84E",
                              @"#E14835",
                              @"#EF8733",
                              @"#5ECDD7",
                              @"#CC7CCC",
                              @"#F5C042",];
    
    id chart_data = [MappingSyntaxInterpreter getJsonWithPath:opt :self.dataPath];
    
    id list = chart_data[@"list"];
    self.list = list;
    id keys = chart_data[@"keys"];
    
    id values = list[0];
    NSMutableArray *entiries = [[NSMutableArray alloc] init];
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    for (int i = 0; i < [keys count]; i++)
    {
        id m = keys[i];
        NSString* key = m[@"key"];
        NSString* legend = m[@"legend"];
        NSString* color = m[@"color"];
        if(!color)
            color = DEFAULT_COLOR_LIST[i % [DEFAULT_COLOR_LIST count]];
        [colors addObject:[WildCardUtil colorWithHexString:color]];
        double value = [values[key] floatValue];
        
        [entiries addObject:[[PieChartDataEntry alloc] initWithValue:value label:legend]];
    }
    
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithEntries:entiries label:@""];
    
    dataSet.drawIconsEnabled = NO;
    
    dataSet.sliceSpace = 2.0;
    dataSet.iconsOffset = CGPointMake(0, 40);
    
    dataSet.colors = colors;
    
    PieChartData *data = [[PieChartData alloc] initWithDataSet:dataSet];
    
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 1;
    pFormatter.multiplier = @1.f;
    pFormatter.percentSymbol = @" %";
    [data setValueFormatter:[[ChartDefaultValueFormatter alloc] initWithFormatter:pFormatter]];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.f]];
    [data setValueTextColor:UIColor.blackColor];
    
    self.pie_chart.data = data;
    [self.pie_chart highlightValues:nil];
}

- (void)updateBarChart:(id)opt {
    
    id DEFAULT_COLOR_LIST = @[@"#6597EA",
                              @"#9AB84E",
                              @"#E14835",
                              @"#EF8733",
                              @"#5ECDD7",
                              @"#CC7CCC",
                              @"#F5C042",];
    
    id chart_data = [MappingSyntaxInterpreter getJsonWithPath:opt :self.dataPath];
    id list = chart_data[@"list"];
    self.list = list;
    id keys = chart_data[@"keys"];
    
    
    if(chart_data[@"ymax"]) {
        _chart.leftAxis.axisMaximum = [chart_data[@"ymax"] floatValue]; // this replaces startAtZero = YES
    }
    if(chart_data[@"ymin"]) {
        _chart.leftAxis.axisMinimum = [chart_data[@"ymin"] floatValue]; // this replaces startAtZero = YES
    }
    if(chart_data[@"ylabel_count"]) {
        _chart.leftAxis.labelCount = [chart_data[@"ylabel_count"] intValue];
    }
    if(chart_data[@"ylabel_granularity"]) {
        _chart.leftAxis.granularity = [chart_data[@"ylabel_granularity"] intValue];
    }
    
    
    
    if([@"bar" isEqualToString:self.type]) {
        id dataSetList = [@[] mutableCopy];
        for(int i=0;i<[keys count];i++) {
            id m = keys[i];
            NSString* key = m[@"key"];
            NSString* color = m[@"color"];
            if(!color)
                color = DEFAULT_COLOR_LIST[i];
            
            NSString* legend = m[@"legend"];
            if(!legend)
                legend = @"No Legend";
            
            id values = [@[] mutableCopy];
            for (int j=0; j<[list count]; j++) {
                id d = list[j];
                double v = [d[key] doubleValue];
                [values addObject:[[BarChartDataEntry alloc] initWithX:j y:v]];
            }
            
            BarChartDataSet* s1 = [[BarChartDataSet alloc] initWithEntries:values label:legend];
            [s1 setColor: [WildCardUtil colorWithHexString:color]];
            s1.drawIconsEnabled = NO;
            [dataSetList addObject:s1];
        }

        BarChartData *data = [[BarChartData alloc] initWithDataSets:dataSetList];
        [data setValueFont:[UIFont systemFontOfSize:10.f]];
        data.valueFormatter = self;
        _chart.data = data;
        
        if([dataSetList count] > 1) {
            float groupSpace = 0.3f;
            float barSpace = 0.0f;
            float defaultBarWidth = -1;
            int groupCount = (int)[list count];
            defaultBarWidth = (1 - groupSpace)/[dataSetList count] - barSpace;
            if(defaultBarWidth >=0) {
                data.barWidth = defaultBarWidth;
            }
            if(groupCount != -1) {
                _chart.xAxis.axisMinimum = 0;
                _chart.xAxis.axisMaximum = 0 + [((BarChartView*)_chart).barData groupWidthWithGroupSpace:groupSpace barSpace:barSpace] * groupCount;
                
                _chart.xAxis.centerAxisLabelsEnabled = YES;
            }
            
            [data groupBarsFromX:0 groupSpace:groupSpace barSpace:barSpace];
        }
        
        _chart.xAxis.valueFormatter = self;
        
    } else if([@"line" isEqualToString:self.type]) {
        id dataSetList = [@[] mutableCopy];
        for(int i=0;i<[keys count];i++) {
            id m = keys[i];
            NSString* key = m[@"key"];
            NSString* color = m[@"color"];
            if(!color)
                color = DEFAULT_COLOR_LIST[i];
            
            NSString* legend = m[@"legend"];
            if(!legend)
                legend = @"No Legend";
            
            id values = [@[] mutableCopy];
            for (int j=0; j<[list count]; j++) {
                id d = list[j];
                double v = [d[key] doubleValue];
                [values addObject:[[ChartDataEntry alloc] initWithX:j y:v]];
            }
            
            LineChartDataSet* s1 = [[LineChartDataSet alloc] initWithEntries:values label:legend];
            [s1 setColor: [WildCardUtil colorWithHexString:color]];
            s1.drawIconsEnabled = NO;
            s1.mode = LineChartModeCubicBezier;
            s1.cubicIntensity = 0.2f;
            s1.lineWidth = 2.0f;
            s1.circleRadius = s1.circleHoleRadius = 4.0f;
            s1.circleHoleColor = [WildCardUtil colorWithHexString:color];
            s1.circleColors = @[[WildCardUtil colorWithHexString:color]];
            
            
            [dataSetList addObject:s1];
        }

        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSetList];
        [data setValueFont:[UIFont systemFontOfSize:10.f]];
                
        data.valueFormatter = self;
        _chart.xAxis.valueFormatter = self;
        
        _chart.data = data;
    }
    
}

-(NSString*)stringForValue:(double)value entry:(ChartDataEntry *)entry dataSetIndex:(NSInteger)dataSetIndex viewPortHandler:(ChartViewPortHandler *)viewPortHandler {
    return @"";
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis {
    if(axis == _chart.xAxis) {
        int index = (int)value;
        if(index < [_list count])
            return _list[index][@"name"];
        else
            return [NSString stringWithFormat:@"%d", index];
    } else
        return @"";
}

@end
