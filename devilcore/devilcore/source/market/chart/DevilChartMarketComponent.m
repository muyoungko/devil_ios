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
    } else if([@"line" isEqualToString:self.type]) {
        self.chart = [[LineChartView alloc] init];
    }
    
    _chart.delegate = self;
    
    [self.vv addSubview:self.chart];
    [WildCardConstructor followSizeFromFather:self.vv child:self.chart];
    
    _chart.chartDescription.enabled = NO;
    _chart.maxVisibleCount = 60;
    _chart.pinchZoomEnabled = NO;
    _chart.drawGridBackgroundEnabled = NO;
    
    _chart.xAxis.labelPosition = XAxisLabelPositionBottom;
    _chart.xAxis.drawGridLinesEnabled = NO;
    _chart.xAxis.granularity = 1.0f;
    _chart.xAxis.centerAxisLabelsEnabled = NO;
    _chart.xAxis.labelFont = [UIFont systemFontOfSize:14.f];
    
    _chart.leftAxis.labelCount = 5;
    _chart.leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
    _chart.leftAxis.labelCount = 8;
    _chart.leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    _chart.leftAxis.spaceTop = 0.15;
    _chart.leftAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
    _chart.leftAxis.labelFont = [UIFont systemFontOfSize:14.f];
    
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
    
    _chart.extraBottomOffset = 8.0f;
}

- (void)created {
    [super created];
}


- (void)update:(id)opt {
    [super update:opt];
    
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
