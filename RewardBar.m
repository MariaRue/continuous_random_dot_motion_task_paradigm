classdef RewardBar < handle
    
    properties (SetAccess = private)
        Point
        Money
        HalfLength
        RewardThresh
        RewardAmount
    end
    
    properties (Constant)
        Debug = true;
    end
    
    properties (Transient, Dependent)
        Position
    end
    
    methods
        
        % R = RewardBar( halfLength, rewardThresh, rewardAmount );
        % R = RewardBar( filename, newHalfLength );
        function self = RewardBar(varargin)
            self.clear();
            if nargin > 0
                if ischar(varargin{1})
                    self.load( varargin{:} );
                else
                    self.reset( varargin{:} );
                end
            end
        end
        
        function clear(self)
            self.Point = nan;
            self.Money = nan;
            self.HalfLength = nan;
            self.RewardThresh = nan;
            self.RewardAmount = nan;
        end
        
        % R.reset( halfLength, rewardThresh, rewardAmount );
        function reset(self,hl,rt,ra)
            
            isnum = @(x) isnumeric(x) && isscalar(x);
            ispnum = @(x) isnum(x) && x > 0;
            assert( ispnum(hl) && ispnum(rt) && isnum(ra), 'Inputs should be positive scalars.' );
            
            self.Point = 0;
            self.Money = 0;
            self.HalfLength = hl;
            self.RewardThresh = rt;
            self.RewardAmount = ra;
        end
        
        % [before, after, block] = R.update( amount );
        function [before,after,block] = update(self,x)
           
            a = fix( self.Point / self.RewardThresh );
            b = fix( (self.Point + x) / self.RewardThresh );
            r = (b - a) * self.RewardAmount;
            
            before.pos = self.Position;
            before.mon = self.Money;
            
            self.Point = self.Point + x;
            self.Point = self.Point - self.RewardThresh * fix( self.Point / self.RewardThresh );
            self.Money = self.Money + r;
            if self.Debug
                fprintf( 'Point=%g, Money=%g, Position=%g\n', self.Point, self.Money, self.Position );
            end
            
            after.pos = self.Position;
            after.mon = self.Money;
            
            block.before = before.pos / 2;
            block.after  = after.pos / 2;
            block.interm = (before.pos + after.pos) / 2;
            
        end
        
        function p = get.Position(self)
            p = self.Point / self.RewardThresh;
            p = p - fix(p);
            p = self.HalfLength * p;
        end
        
        function plot(self)
            errorbar( 0, 0, self.HalfLength, 'horizontal', 'LineWidth', 3, 'Color', 'k' ); hold on;
            plot( self.Position, 0, 'rd', 'MarkerSize', 10 ); hold off;
        end
        
        % R.save( filename );
        function dat = save(self,filename)
            dat.Point = self.Point;
            dat.Money = self.Money;
            dat.HalfLength = self.HalfLength;
            dat.RewardThresh = self.RewardThresh;
            dat.RewardAmount = self.RewardAmount;
            save( filename, '-v7', '-struct', 'dat' );
        end
        
        % R.load( filename );
        % R.load( filename, newHalfLength );
        function self = load(self,filename,hl)
            dat = load( filename );
            self.Point = dat.Point;
            self.Money = dat.Money;
            self.HalfLength = dat.HalfLength;
            self.RewardThresh = dat.RewardThresh;
            self.RewardAmount = dat.RewardAmount;
            
            if nargin > 2
                self.HalfLength = hl;
            end
        end
        
    end
    
end